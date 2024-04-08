{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.lf;
in {
  imports = [];
  options.lf = with lib;
  with lib.types; {
    enable = mkEnableOption "";
  };
  config = lib.mkIf cfg.enable {
    programs.lf = {
      enable = true;

      settings = {
        preview = true;
        hidden = true;
        drawbox = true;
        icons = true;
        ignorecase = true;
      };

      commands = {
        delete-trash = ''          ''${{
                    touch "${config.xdg.dataHome}/Trash/info/$(basename $f).trashinfo"

                    echo "[Trash Info]" > "${config.xdg.dataHome}/Trash/info/$(basename $f).trashinfo"
                    echo "Path=$f" >> "${config.xdg.dataHome}/Trash/info/$(basename $f).trashinfo"
                    echo "DeletionDate=$(date +%Y-%m-%dT%H:%M:%S)" >> "${config.xdg.dataHome}/Trash/info/$(basename $f).trashinfo"

                    mv $f ${config.xdg.dataHome}/Trash/files
                  }}'';
        dragon-out = ''%${pkgs.xdragon}/bin/xdragon -a -x "$fx"'';
        editor-open = ''$$EDITOR $f'';
        mkfile = ''          ''${{
                    printf "Dirname: "
                    read DIR

                    if [[ $DIR = */ ]]; then
                      mkdir $DIR
                    else
                      touch $DIR
                    fi
                  }}'';
        mkdir = ''          ''${{
                    printf "Dirname: "
                    read DIR
                    mkdir $DIR
                  }}'';
        trash = ''cd ${config.xdg.dataHome}/Trash/files'';
        trash-recover = ''          ''${{
                    mv $f "$(cat "${config.xdg.dataHome}/Trash/info/$(basename $f).trashinfo" | sed -n '2 p' | tr "=" "\n" | sed -n '2 p')"
                    rm -rf "${config.xdg.dataHome}/Trash/info/$(basename $f).trashinfo"
                  }}'';
      };

      keybindings = {
        "." = "set hidden!";
        "<enter>" = "open";
        a = "mkfile";
        A = "mkdir";
        D = "delete";
        R = "trash-recover";
        ee = "editor-open";
      };

      extraConfig = let
        previewer = pkgs.writeShellScriptBin "pv.sh" ''
          file=$1
          w=$2
          h=$3
          x=$4
          y=$5

          if [[ "$(${pkgs.file}/bin/file -Lb --mime-type "$file")" =~ ^image ]]; then
            ${pkgs.kitty}/bin/kitty +kitten icat --silent --stdin no --transfer-mode file --place "''${w}x''${h}@''${x}x''${y}" "$file" < /dev/null > /dev/tty
            exit 1
          fi

          ${pkgs.pistol}/bin/pistol "$file"
        '';
        cleaner = pkgs.writeShellScriptBin "clean.sh" ''
          ${pkgs.kitty}/bin/kitty +kitten icat --clear --stdin no --silent --transfer-mode file < /dev/null > /dev/tty
        '';
      in ''
        set cleaner ${cleaner}/bin/clean.sh
        set previewer ${previewer}/bin/pv.sh
      '';
    };
  };
}
