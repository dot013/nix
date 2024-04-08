{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.krita;
in {
  imports = [];
  options.krita = with lib;
  with lib.types; {
    enable = mkEnableOption "";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [krita];

    home.file."${config.xdg.configHome}/kritarc".source = ./kritarc;
    home.file."${config.xdg.configHome}/kritashortcutsrc".source = ./kritashortcutsrc;
  };
}
