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
    package = mkOption {
      type = with types; package;
      default = pkgs.godot;
    };
    templates-package = mkOption {
      type = with types; package;
      default = pkgs.godot-export-templates-bin;
    };
  };
  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    home.file = let
      godotname = builtins.replaceStrings ["-"] ["."] cfg.templates-package.version;
    in {
      ".local/share/godot/export_templates/${godotname}" = {
        source = "${cfg.templates-package}/share/godot/export_templates/${godotname}";
      };
    };
  };
}
