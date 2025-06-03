{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    concatStringsSep
    literalExpression
    mapAttrsToList
    mkIf
    mkOption
    types
    ;

  cfg = config.programs.qutebrowser;

  profileType = with lib;
  with types;
    submodule ({
      config,
      lib,
      ...
    }: let
      scfg = config;
    in {
      options = with lib; {
        name = mkOption {
          type = with types; nullOr str;
          default = null;
        };
        extendDefault = mkOption {
          type = with types; bool;
          default = true;
        };
        titleFormat = mkOption {
          type = with types; str;
          default = "{perc}{current_title}{title_sep} qutebrowser ({profile_name})";
        };
        desktopName = mkOption {
          type = with types; nullOr str;
          default = null;
        };
        aliases = mkOption {
          type = with types; attrsOf str;
          default = {};
        };
        loadAutoconfig = mkOption {
          type = with types; bool;
          default = cfg.loadAutoconfig;
        };
        searchEngines = mkOption {
          type = with types; attrsOf str;
          default = {};
        };
        settings = mkOption {
          type = with types; attrsOf anything;
          default = {};
        };
        keyMappings = mkOption {
          type = with types; attrsOf str;
          default = {};
        };
        enableDefaultBindings = mkOption {
          type = with types; bool;
          default = cfg.enableDefaultBindings;
        };
        keyBindings = mkOption {
          type = with types; attrsOf (attrsOf (nullOr (separatedString " ;; ")));
          default = {};
        };
        quickmarks = mkOption {
          type = with types; attrsOf str;
          default = {};
          apply = v:
            if scfg.extendDefault
            then cfg.quickmarks // v
            else v;
        };
        greasemonkey = mkOption {
          type = with types; listOf package;
          default = [];
          apply = v:
            if scfg.extendDefault
            then cfg.greasemonkey ++ v
            else v;
        };
        extraConfig = mkOption {
          type = with types; lines;
          default = "";
        };
      };
    });

  formatLine = o: n: v: let
    formatValue = v:
      if v == null
      then "None"
      else if builtins.isBool v
      then
        (
          if v
          then "True"
          else "False"
        )
      else if builtins.isString v
      then ''"${v}"''
      else if builtins.isList v
      then "[${concatStringsSep ", " (map formatValue v)}]"
      else builtins.toString v;
  in
    if builtins.isAttrs v
    then concatStringsSep "\n" (mapAttrsToList (formatLine "${o}${n}.") v)
    else "${o}${n} = ${formatValue v}";

  formatDictLine = o: n: v: ''${o}['${n}'] = "${v}"'';

  formatKeyBindings = m: b: let
    formatKeyBinding = m: k: c:
      if c == null
      then ''config.unbind("${k}", mode="${m}")''
      else ''config.bind("${k}", "${lib.escape [''"''] c}", mode="${m}")'';
  in
    concatStringsSep "\n" (mapAttrsToList (formatKeyBinding m) b);

  formatQuickmarks = n: s: "${n} ${s}";
in
  with lib; {
    options.programs.qutebrowser = {
      profileChooser = mkOption {
        type = with types; either bool (enum ["override"]);
        default = "override";
      };
      profileChooserDMenu = mkOption {
        type = with types; package;
        default = pkgs.writeShellScriptBin "rofi" "${getExe config.programs.rofi.finalPackage} -dmenu $@";
      };
      profileChooserUserscript = mkOption {
        type = with types; nullOr str;
        default = "W";
      };
      profiles = mkOption {
        type = with types; attrsOf profileType;
        default = {};
      };
    };
    config = let
      profiles = mapAttrsToList (n: v: n) cfg.profiles;
      profilesFile = pkgs.writeText "qutebrowser-profiles" (concatStringsSep "\n" (["DEFAULT"] ++ profiles));

      chooser = pkgs.writeShellScriptBin "qutebrowser-chooser" ''
        profile="$(cat ${profilesFile} | ${getExe cfg.profileChooserDMenu})"
        case "$profile" in
          "DEFAULT")
            ${getExe pkgs.qutebrowser} $@
            ;;
          ${concatMapStringsSep "\n" (n: let
            profileDir = "${config.xdg.dataHome}/qutebrowser-profiles/${n}";
          in ''
            "${n}")
              ${getExe pkgs.qutebrowser} -B ${profileDir} -C ${profileDir}/config.py --desktop-file-name qutebrowser-profile-${n} $@
              ;;
          '')
          profiles}
        esac
      '';
      userscript = pkgs.writeShellScriptBin "qutebrowser-profiles-userscript" ''
        function close() {
          echo "close" >> "$QUTE_FIFO"
        }
        ${getExe chooser} & close
      '';
    in
      mkIf (cfg.enable && cfg.profiles != {}) {
        programs.qutebrowser.package = pkgs.stdenv.mkDerivation {
          inherit (pkgs.qutebrowser) name pname meta;
          buildCommand = let
            desktopEntry = pkgs.makeDesktopItem {
              name = "qutebrowser";
              desktopName = "qutebrowser";
              exec = "${getExe (
                if cfg.profileChooser == "override"
                then chooser
                else pkgs.package
              )} %u";
            };
            chooserDesktopEntry = pkgs.makeDesktopItem {
              name = "qutebrowser chooser";
              desktopName = "qutebrowser-chooser";
              exec = "${getExe chooser} %u";
            };
          in ''
            mkdir -p $out/bin
            cp ${getExe pkgs.qutebrowser} $out/bin
            ${
              if cfg.profileChooser != false
              then "cp ${getExe chooser} $out/bin"
              else ""
            }

            mkdir -p $out/share/applications
            cp ${desktopEntry}/share/applications/qutebrowser.desktop $out/share/applications/qutebrowser.desktop
            ${
              if cfg.profileChooser == true
              then "cp ${chooserDesktopEntry}/share/applications/qutebrowser-chooser.desktop $out/share/applications/qutebrowser-chooser.desktop"
              else ""
            }
          '';
          dontBuild = true;
        };

        xdg.desktopEntries = mergeAttrsList (mapAttrsToList (n: v: let
            profileDir = "qutebrowser-profiles/${n}";
          in {
            "qutebrowser-profile-${n}" = {
              name =
                if isNull v.desktopName
                then "${
                  if isNull v.name
                  then n
                  else v.name
                } (qutebrowser profile)"
                else v.desktopName;
              exec =
                "${getExe pkgs.qutebrowser}"
                + " -B ${config.xdg.dataHome}/${profileDir}"
                + " -C ${config.xdg.dataHome}/${profileDir}/config.py"
                + " --desktop-file-name qutebrowser-profile-${n}"
                + " %u";
            };
          })
          cfg.profiles);

        xdg.dataFile = mergeAttrsList (mapAttrsToList (n: v: let
            profileDir = "qutebrowser-profiles/${n}";
          in {
            "${profileDir}/config.py" = {
              text = concatStringsSep "\n" (
                [
                  (
                    if v.loadAutoconfig
                    then "config.load_autoconfig()"
                    else "config.load_autoconfig(False)"
                  )
                ]
                ++ lib.optional (v.titleFormat != "") ''
                  c.window.title_format = '${replaceStrings ["{profile}" "{profile_name}"] [
                      n
                      (
                        if isNull v.name
                        then n
                        else v.name
                      )
                    ]
                    v.titleFormat}'
                ''
                ++ lib.optional (v.extendDefault) ''
                  config.source(r'${config.xdg.configHome}/qutebrowser/config.py')
                ''
                ++ mapAttrsToList (formatLine "c.") v.settings
                ++ mapAttrsToList (formatDictLine "c.aliases") v.aliases
                ++ mapAttrsToList (formatDictLine "c.url.searchengines") v.searchEngines
                ++ mapAttrsToList (formatDictLine "c.bindings.key_mappings") v.keyMappings
                ++ lib.optional (!v.enableDefaultBindings) "c.bindings.default = {}"
                ++ mapAttrsToList formatKeyBindings v.keyBindings
                ++ lib.optional (cfg.profileChooserUserscript != "" && !(isNull cfg.profileChooserUserscript))
                "config.bind(\"${cfg.profileChooserUserscript}\", \"spawn --userscript ${getExe userscript}\", mode=\"normal\")"
                ++ lib.optional (v.extraConfig != "") cfg.extraConfig
              );
              onChange = ''
                hash="$(echo -n "$USER" | md5sum | cut -d' ' -f1)"
                socket="''${XDG_RUNTIME_DIR:-/run/user/$UID}/qutebrowser/ipc-$hash"
                if [[ -S $socket ]]; then
                  command=${
                  lib.escapeShellArg (
                    builtins.toJSON {
                      args = [":config-source"];
                      target_arg = null;
                      protocol_version = 1;
                    }
                  )
                }
                  echo "$command" | ${pkgs.socat}/bin/socat -lf /dev/null - UNIX-CONNECT:"$socket"
                fi
                unset hash socket command
              '';
            };

            "${profileDir}/quickmarks" = mkIf (v.quickmarks != {}) {
              text = concatStringsSep "\n" (
                mapAttrsToList formatQuickmarks v.quickmarks
              );
            };

            "${profileDir}/data/greasemonkey" = mkIf (v.greasemonkey != []) {
              source = pkgs.linkFarmFromDrvs "greasemonkey-userscripts" v.greasemonkey;
            };
          })
          cfg.profiles);
      };
  }
