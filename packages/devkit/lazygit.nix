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
          in
            with colors; {
              activeBorderColor = [base07 "bold"];
              inactiveBorderColor = [base04];
              searchingActiveBorderColor = [base02 "bold"];
              optionsTextColor = [base06];
              selectedLineBgColor = [base03];
              cherryPickedCommitBgColor = [base02];
              cherryPickedCommitFgColor = [base03];
              unstagedChangesColor = [base08];
              defaultFgColor = [base05];
            };
        }
        // settings))}'
    '';
  }
  // {inherit (lazygit) name pname meta;})
