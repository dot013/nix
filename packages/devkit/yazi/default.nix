{
  formats,
  lib,
  wrapPackage,
  pkgs,
  stdenv,
  # Package
  yazi ? pkgs.yazi,
  # Runtime Inputs
  dragon-drop ? pkgs.dragon-drop,
  jq ? pkgs.jq,
  poppler ? pkgs.poppler,
}:
with lib; let
  toml = formats.toml {};

  init = pkgs.writeText "init.lua" ''
    ${builtins.readFile ./init.lua}
  '';
  keymapsToml = toml.generate "keymaps.toml" {
    mgr.prepend_keymap = map (v: {
      on = [(toString v)];
      run = "plugin relative-motions ${(toString v)}";
    }) (range 1 9);
    manager.keymap = [
      {
        on = "<C-n>";
        run = "shell -- dragon -x -i -T %s1";
      }
    ];
  };
  themeToml = toml.generate "theme.toml" {};
  yaziToml = toml.generate "yazi.toml" {
    manager = {
      linemode = "size";

      show_hidden = true;
      show_symlink = true;

      sort_by = "natural";
      sort_dir_first = true;
      sort_sensitive = false;
      sort_translit = true;
    };
  };
  plugins = {};
in
  wrapPackage {
    inherit pkgs;
    package = yazi;
    env.YAZI_CONFIG_HOME = stdenv.mkDerivation {
      name = "config-home";
      src = ./.;
      installPhase = ''
        mkdir -p $out
        cp ${init} $out/init.lua
        cp ${keymapsToml} $out/keymaps.toml
        cp ${themeToml} $out/theme.toml
        cp ${yaziToml} $out/yazi.toml

        ${join "\n" (mapAttrsToList (n: v: ''
            mkdir -p $out/plugins/${n}
            cp -r ${v}/* $out/plugins/${n}
          '')
          plugins)}
      '';
    };
    runtimeInputs = [dragon-drop jq poppler];
  }
