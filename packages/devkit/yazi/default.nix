{
  formats,
  lib,
  makeWrapper,
  pkgs,
  stdenv,
  symlinkJoin,
  yazi ? pkgs.yazi,
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
  symlinkJoin ({
      paths = [yazi];
      nativeBuildInputs = [makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/yazi \
          --set YAZI_CONFIG_HOME ${stdenv.mkDerivation {
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
        }} \
          --set PATH ${with pkgs;
          makeBinPath [
            dragon-drop
            jq
            poppler
          ]}
      '';
    }
    // {inherit (yazi) name pname meta;})
