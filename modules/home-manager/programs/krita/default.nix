{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.krita;
in {
  imports = [];
  options.programs.krita = with lib;
  with lib.types; {
    enable = mkEnableOption "";
  };
  config = with lib;
    mkIf cfg.enable {
      home.packages = with pkgs; [krita];

      home.file."${config.xdg.configHome}/kritarc".source = ./kritarc;
      home.file."${config.xdg.configHome}/kritashortcutsrc".source = ./kritashortcutsrc;
    };
}
