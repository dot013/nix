{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.nih;
in {
  imports = [
    ./cli.nix
  ];
  options.programs.nih = with lib;
  with lib.types; {
    enable = mkEnableOption "";
    host = mkOption {
      type = str;
    };
    flakeDir = mkOption {
      type = str;
    };
  };
  config = with lib; mkIf cfg.enable {};
}
