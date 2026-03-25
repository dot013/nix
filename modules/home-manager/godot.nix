{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.godot;
in {
  options.programs.godot = {
    enable = mkEnableOption "";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [godot];

    home.file = let
      godottemplates = pkgs.godot-export-templates-bin;
      godotname = builtins.replaceStrings ["-"] ["."] godottemplates.version;
    in {
      ".local/share/godot/export_templates/${godotname}" = {
        source = "${godottemplates}/share/godot/export_templates/${godotname}";
      };
    };
  };
}
