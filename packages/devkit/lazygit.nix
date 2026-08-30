{
  lib,
  pkgs,
  wrapPackage,
  writers,
  # Package
  lazygit ? pkgs.lazygit,
  pager ? pkgs.delta,
}:
with lib;
  wrapPackage {
    inherit pkgs;
    package = lazygit;
    flags = {
      "--use-config-file" =
        writers.writeJSON "config"
        {
          git.pagers = [
            {
              colorArg = "always";
              pager = "${getExe pager} --dark --paging=never";
            }
          ];
          gui.theme = with (import ./colors.nix); {
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
        };
    };
  }
