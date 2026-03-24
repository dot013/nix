{
  symlinkJoin,
  makeWrapper,
  pkgs,
  lib,
  zellij ? pkgs.zellij,
  shell ? pkgs.zsh,
}:
symlinkJoin {
  paths = [zellij];
  nativeBuildInputs = [makeWrapper];
  postBuild = ''
    wrapProgram $out/bin/zellij \
      --set-default ZELLIJ_CONFIG_FILE ${
      let
        colors = import ../colors.nix;
      in
        pkgs.writeText "config.kdl" ''
          plugins {
            zellij-sessionizer location="file:${builtins.fetchurl {
            url = "https://github.com/laperlej/zellij-sessionizer/releases/download/v0.4.3/zellij-sessionizer.wasm";
            sha256 = "0d43jhlhm7p8pvd8kcylfbfy3dahr8q4yngpnjyqivapwip9csq0";
          }}"

            tab-bar location="zellij:tab-bar"
            status-bar location="zellij:status-bar"
            compact-bar location="zellij:compact-bar"
            session-manager location="zellij:session-manager"
          }

          default_shell "${lib.getExe shell}"

          themes {
            defautl {
              bg "${colors.base03}";
              fg "${colors.base05}";
              red "${colors.base01}";
              green "${colors.base0B}";
              blue "${colors.base0D}";
              yellow "${colors.base0A}";
              magenta "${colors.base0E}";
              orange "${colors.base09}";
              cyan "${colors.base0C}";
              black "${colors.base00}";
              white "${colors.base07}";
            }
          }
          theme "default"

          ${builtins.readFile ./config.kdl}
        ''
    }
  '';
  inherit (zellij) meta name pname version;
}
