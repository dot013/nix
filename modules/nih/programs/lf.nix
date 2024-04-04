{ config, lib, pkgs, ... }:

let
  cfg = config.programs.lf;
in
{
  imports = [ ];
  options.programs.lf = with lib; with lib.types; {
    cmds = {
      mkfile = mkOption {
        type = bool;
        default = true;
      };
      editor-open = mkOption {
        type = bool;
        default = true;
      };
      dragon-out = mkOption {
        type = bool;
        default = true;
      };
    };
    extraCfg = mkOption {
      type = lines;
      default = "";
    };
    filePreviewer = mkOption {
      type = bool;
      default = true;
    };
  };
  config = with lib; mkIf cfg.enable {
    programs.lf = {
      commands = {
        dragon-out = mkIf cfg.cmds.dragon-out ''%${pkgs.xdragon}/bin/xdragon -a -x "$fx"'';
        editor-open = mkIf cfg.cmds.editor-open ''$$EDITOR $f'';
        mkfile = mkIf cfg.cmds.mkfile ''''${{
          printf "Dirname: "
          read DIR

          if [[ $DIR = */ ]]; then
            mkdir $DIR
          else
            touch $DIR
          fi
        }}'';
      };

      extraConfig =
        let
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
        in
        mkDefault ''
          ${if cfg.filePreviewer then ''
            set cleaner ${cleaner}/bin/clean.sh
            set previewer ${previewer}/bin/pv.sh
          '' else ""}

          ${cfg.extraCfg}
        '';
    };
  };
}
