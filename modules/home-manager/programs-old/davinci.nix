{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.davinci;
in {
  imports = [];
  options.davinci = with lib;
  with lib.types; {
    enable = mkEnableOption "";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      davinci-resolve
    ];
  };
}
