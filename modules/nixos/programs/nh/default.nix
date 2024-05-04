{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.nh;
  wrapper = pkgs.writeShellScriptBin "nh" ''
    function alejandra() { ${pkgs.alejandra}/bin/alejandra "$@"; }
    function git() { ${pkgs.git}/bin/git "$@"; }
    function lazygit() { ${pkgs.lazygit}/bin/lazygit "$@"; }
    function nh() { ${pkgs.nh}/bin/nh "$@"; }
    function shellharden() { ${pkgs.shellharden}/bin/shellharden "$@"; }

    FLAKE_DIR=${toString cfg.flake}

    ${builtins.readFile ./wrapper.sh}
  '';
in {
  options.programs.nh = with lib; with lib.types; {};
  config = with lib;
    mkIf cfg.enable {
      programs.nh.package = wrapper;
      programs.nh.clean.enable = mkDefault true;
    };
}
