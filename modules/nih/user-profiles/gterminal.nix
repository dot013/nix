{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.gterminal;
in {
  imports = [];
  options.profiles.gterminal = with lib;
  with lib.types; {
    enable = mkEnableOption "";
  };
  config = with lib;
    mkIf cfg.enable {
      home.packages = with pkgs; [
        neovim
        gcc
        wget
        git
        tmux
        lazygit
        nixpkgs-fmt
        nixpkgs-lint
      ];
      programs = {
        direnv.enable = true;

        lf.enable = true;

        neovim.enable = true;

        starship.enable = true;

        tmux.baseIndex = 1;
        tmux.enable = true;
        tmux.extraConfig = ''
          set -sg terminal-overrides ",*:RGB"

          set -g renumber-windows on

          bind -T prefix / split-window -v -c "#''''{pane_current_path}"
          bind -T prefix \\ split-window -h -c "#''''{pane_current_path}"
        '';
        tmux.keyMode = "vi";
        tmux.mouse = true;
        tmux.prefix = "C-Space";
        tmux.plugins = with pkgs; [
          {
            plugin = tmuxPlugins.catppuccin.overrideAttrs (_: {
              src = fetchFromGitHub {
                owner = "guz013";
                repo = "frappuccino-tmux";
                rev = "4255b0a769cc6f35e12595fe5a33273a247630aa";
                sha256 = "0k8yprhx5cd8v1ddpcr0dkssspc17lq2a51qniwafkkzxi3kz3i5";
              };
            });
            extraConfig = ''
              set -g @catppuccin_window_left_separator ""
              set -g @catppuccin_window_right_separator " "
              set -g @catppuccin_window_middle_separator " █"
              set -g @catppuccin_window_number_position "right"

              set -g @catppuccin_window_default_fill "number"
              set -g @catppuccin_window_default_text "#W"

              set -g @catppuccin_window_current_fill "number"
              set -g @catppuccin_window_current_text "#W"

              set -g @catppuccin_status_modules_right "application directory session"
              set -g @catppuccin_status_left_separator  " "
              set -g @catppuccin_status_right_separator ""
              set -g @catppuccin_status_right_separator_inverse "no"
              set -g @catppuccin_status_fill "icon"
              set -g @catppuccin_status_connect_separator "no"

              set -g @catppuccin_directory_text "#{pane_current_path}"
            '';
          }
          {
            plugin = tmuxPlugins.better-mouse-mode;
            extraConfig = "set-option -g mouse on";
          }
          {
            plugin = tmuxPlugins.mkTmuxPlugin {
              pluginName = "tmux.nvim";
              version = "unstable-2024-04-05";
              src = fetchFromGitHub {
                owner = "aserowy";
                repo = "tmux.nvim";
                rev = "63e9c5e054099dd30af306bd8ceaa2f1086e1b07";
                sha256 = "0ynzljwq6hv7415p7pr0aqx8kycp84p3p3dy4jcx61dxfgdpgc4c";
              };
            };
            extraConfig = '''';
          }
        ];

        tmux.shell = "${pkgs.zsh}/bin/zsh";
        tmux.terminal = "screen-256color";

        wezterm = mkIf (config._nih.type != "server") {
          enable = true;
          config = {
            default_prog = ["zsh" "--login"];
            enable_wayland = false;
            enable_tab_bar = false;
            font = "lua wezterm.font(\"Fira Code\")";
            font_size = 10;
          };
        };

        zsh.enable = true;
        zsh.enableAutosuggestions = true;
        zsh.enableCompletion = true;
        zsh.initExtra = ''
          export GPG_TTY=$(tty)

          alias tmux="tmux -f ${config.xdg.configHome}/tmux/tmux.conf";
        '';
      };
    };
}
