{
  symlinkJoin,
  makeWrapper,
  pkgs,
  lib,
  lazygit ? pkgs.lazygit,
  settings ? {},
}:
symlinkJoin ({
    paths = [lazygit];
    nativeBuildInputs = [makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/lazygit \
        --add-flags '--use-config-file' \
        --add-flags '${pkgs.writeText "config.yml" (builtins.toJSON ({
          git.pagers = [
            {
              colorArg = "always";
              pager = "${lib.getExe pkgs.delta} --dark --paging=never";
            }
          ];
          gui.theme = let
            colors = import ./colors.nix;
          in {
            activeBorderColor = [colors.base07 "bold"];
            inactiveBorderColor = [colors.base04];
            searchingActiveBorderColor = [colors.base02 "bold"];
            optionsTextColor = [colors.base06];
            selectedLineBgColor = [colors.base03];
            cherryPickedCommitBgColor = [colors.base02];
            cherryPickedCommitFgColor = [colors.base03];
            unstagedChangesColor = [colors.base08];
            defaultFgColor = [colors.base05];
          };
        }
        // settings))}'
    '';
  }
  // {inherit (lazygit) name pname meta;})
