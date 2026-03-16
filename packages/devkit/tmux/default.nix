{
  symlinkJoin,
  makeWrapper,
  pkgs,
  lib,
  fetchFromGitHub,
  tmux ? pkgs.tmux,
  fzf ? pkgs.fzf,
  shell ? pkgs.zsh,
}: let
  # colors = import ../colors.nix;
  sessionizer = pkgs.writeShellScriptBin "sessionizer" ''
    function tmux() { ${lib.getExe tmux} "$@"; }
    function fzf() { ${lib.getExe fzf} "$@"; }

    ${builtins.readFile ./sessionizer.sh}
  '';

  plugins = with pkgs.tmuxPlugins; [
    sensible

    better-mouse-mode
    continuum
    resurrect

    (catppuccin.overrideAttrs (_: {
      src = fetchFromGitHub {
        owner = "guz013";
        repo = "frappuccino-tmux";
        rev = "4255b0a769cc6f35e12595fe5a33273a247630aa";
        sha256 = "0k8yprhx5cd8v1ddpcr0dkssspc17lq2a51qniwafkkzxi3kz3i5";
      };
    }))
  ];

  cfg = pkgs.writeText "tmux.conf" ''
    ${(lib.concatMapStringsSep "\n\n" (p: ''
        run-shell ${p.rtp}
      '')
      plugins)}

    set -g default-shell "${lib.getExe shell}"

    ${builtins.readFile ./config.conf}

    bind -T prefix g run-shell "tmux neww ${lib.getExe sessionizer}"
  '';
in
  symlinkJoin ({
      paths = [tmux];
      nativeBuildInputs = [makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/tmux  \
          --add-flags '-f' --add-flags '${cfg}'
      '';
    }
    // {inherit (tmux) name pname man meta;})
