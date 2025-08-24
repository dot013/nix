{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.zen-browser;
  configDir = "${config.home.homeDirectory}/.zen";

  # INFO: Read default shortcuts and transform them to the same attrsOf submodule structure.
  defaultShortcuts = pipe (with builtins; (fromJSON (readFile ./default_shortcuts.json)).shortcuts) [
    (map (v:
      nameValuePair (
        # HACK: Since some of the default shortcuts have a null ID, we create
        # a ID with null + group + (key or keycode). This ID will not be used
        # in the final JSON file, and is just here since Nix can't have
        # multiple attributes with the same name.
        if isNull v.id
        then "${toString v.id}-${v.action}-${v.group}-${
          if v?key
          then v.key
          else v.keycode
        }"
        else v.id
      )
      v))
    listToAttrs
  ];
in {
  imports = [inputs.zen-browser.homeModules.twilight];
  options.programs.zen-browser = {
    profiles = mkOption {
      type = with types;
        attrsOf (submodule ({...}: {
          options = {
            shortcutsForce = mkEnableOption "";
            shortcuts = mkOption {
              type = attrsOf (submodule ({
                config,
                name,
                ...
              }: let
                default = defaultShortcuts.${name};
              in {
                options = {
                  id = mkOption {
                    type = nullOr str;
                    default = name;
                  };
                  key = mkOption {
                    type = nullOr str;
                    default = optionalString (config.keycode == "") default.key;
                    apply = v:
                      if isNull v
                      then ""
                      else v;
                  };
                  keycode = mkOption {
                    type = nullOr str;
                    default = optionalString (config.key == "") default.keycode;
                    apply = v:
                      if isNull v
                      then ""
                      else v;
                  };
                  group = mkOption {
                    type = enum (lib.unique (mapAttrsToList (_: s: s.group) defaultShortcuts));
                    default = default.group;
                  };
                  l10nId = mkOption {
                    type = enum (lib.unique (mapAttrsToList (_: s: s.l10nId) defaultShortcuts));
                    default = default.l10nId;
                  };
                  modifiers = {
                    control = mkEnableOption "";
                    alt = mkEnableOption "";
                    shift = mkEnableOption "";
                    meta = mkEnableOption "";
                    accel = mkEnableOption "";
                  };
                  action = mkOption {
                    type = enum (lib.unique (mapAttrsToList (_: s: s.action) defaultShortcuts));
                    default = default.action;
                  };
                  disabled = mkOption {
                    type = bool;
                    default = default.disabled;
                  };
                  reserved = mkOption {
                    type = bool;
                    default = default.reserved;
                  };
                  internal = mkOption {
                    type = bool;
                    default = default.internal;
                  };
                };
              }));
              default = {};
            };
            # FIXME: Zen does not update zen-themes.css
            # modsForce = mkEnableOption "";
            # mods = mkOption {
            #   type = attrsOf (
            #     either
            #     path
            #     (submodule ({name, ...}: {
            #       options = {
            #         id = mkOption {
            #           type = str;
            #           default = name;
            #         };
            #         name = mkOption {
            #           type = str;
            #         };
            #         description = mkOption {
            #           type = str;
            #           default = "";
            #         };
            #         homepage = mkOption {
            #           type = str;
            #           default = "";
            #         };
            #         style = mkOption {
            #           type = str;
            #         };
            #         readme = mkOption {
            #           type = str;
            #           default = "";
            #         };
            #         image = mkOption {
            #           type = str;
            #           default = "";
            #         };
            #         author = mkOption {
            #           type = str;
            #           default = "";
            #         };
            #         version = mkOption {
            #           type = str;
            #           default = "";
            #         };
            #         tags = mkOption {
            #           type = listOf str;
            #           default = [];
            #         };
            #         createdAt = mkOption {
            #           type = str;
            #           default = "";
            #         };
            #         updatedAt = mkOption {
            #           type = str;
            #           default = "";
            #         };
            #         enabled = mkOption {
            #           type = bool;
            #           default = true;
            #         };
            #       };
            #     }))
            #   );
            #   apply = with builtins;
            #     v:
            #       mapAttrs (n: v:
            #         if (isPath v || isStringLike v)
            #         then fromJSON (readFile v)
            #         else v)
            #       v;
            #   default = {};
            # };
          };
        }));
    };
  };
  config = mkIf cfg.enable {
    home.file =
      concatMapAttrs (profileName: profile: {
        "${configDir}/${profileName}/zen-keyboard-shortcuts.json" = mkIf (profile.shortcuts != {}) {
          text = builtins.toJSON {shortcuts = mapAttrsToList (_: v: v) (defaultShortcuts // profile.shortcuts);};
          force = profile.shortcutsForce;
        };
        # "${configDir}/${profileName}/zen-themes.json" = mkIf (profile.mods != {}) {
        #   text = builtins.toJSON profile.mods;
        #   force = profile.modsForce;
        # };
      })
      cfg.profiles;
  };
}
