{
  formats,
  lib,
  pkgs,
  wrapPackage,
  # Package
  ghostty ? pkgs.ghostty-bin,
  command ? null,
}:
with lib; let
  kvFmt = formats.keyValue {listsAsDuplicateKeys = true;};
  colors = import ./colors.nix;
in
  wrapPackage {
    inherit pkgs;
    package = ghostty;
    flagSeparator = "=";
    args =
      [
        "--gtk-single-instance=true"
        "--config-file=${
          kvFmt.generate "config" {
            font-family = [
              "FiraCode Nerd Font"
              "Noto Color Emoji"
            ];
            font-size = 12;
            background = colors.base00;
            background-opacity = 0.9;
            cursor-color = colors.base05;
            foreground = colors.base05;
            gtk-titlebar = false;
            gtk-titlebar-hide-when-maximized = true;
            palette = [
              "0=${colors.base00}"
              "1=${colors.base08}"
              "2=${colors.base0B}"
              "3=${colors.base0A}"
              "4=${colors.base0D}"
              "5=${colors.base0E}"
              "6=${colors.base0C}"
              "7=${colors.base05}"
              "8=${colors.base03}"
              "9=${colors.base08}"
              "10=${colors.base0B}"
              "11=${colors.base0A}"
              "12=${colors.base0D}"
              "13=${colors.base0E}"
              "14=${colors.base0C}"
              "15=${colors.base07}"
            ];
            selection-background = colors.base02;
            selection-foreground = colors.base07;
          }
        }"
      ]
      ++ optionals (!isNull command) [
        "-e"
        command
      ];
    filesToPatch = [
      "share/dbus-1/services/com.mitchellh.ghostty.service"
      "share/systemd/user/app-com.mitchellh.ghostty.service"
    ];
  }
