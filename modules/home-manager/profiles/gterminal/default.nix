{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.gterminal;

  PATHS =
    lib.strings.concatMapStringsSep " "
    (p: (builtins.replaceStrings ["~/"] ["${config.home.homeDirectory}/"] p))
    cfg.sessionizer.paths;

  sessionizer = pkgs.writeShellScriptBin "sessionizer" ''
    function tmux() { ${pkgs.tmux}/bin/tmux "$@"; }
    function fzf() { ${pkgs.fzf}/bin/fzf "$@"; }

    PATHS="${PATHS}"

    ${builtins.readFile ./sessionizer.sh}
  '';
in {
  imports = [
    ../../programs/wezterm.nix
    ../../programs/neovim.nix
  ];
  options.profiles.gterminal = with lib;
  with lib.types; {
    enable = mkEnableOption "";
    emulator = {
      enable = mkOption {
        type = bool;
        default = true;
      };
      pkg = mkOption {
        type = package;
        default = pkgs.alacritty;
      };
      bin = mkOption {
        type = str;
        default = "${cfg.emulator.pkg}/bin/alacritty";
      };
    };
    sessionizer = {
      enable = mkOption {
        type = bool;
        default = true;
      };
      paths = mkOption {
        type = listOf str;
        default = [];
      };
    };
    shell = {
      pkg = mkOption {
        type = package;
        default = pkgs.zsh;
      };
      bin = mkOption {
        type = str;
        default = "${pkgs.zsh}/bin/zsh";
      };
      defaultArgs = mkOption {
        type = listOf str;
        default = ["--login"];
      };
    };
  };
  config = with lib;
    mkIf cfg.enable {
      home.packages = with pkgs; [
        git
        lazygit
        gcc # Added temporally so my neovim config doesn't break
        wget
        nixpkgs-fmt
        nixpkgs-lint
        alejandra
        shellharden
      ];
      programs = {
        direnv.enable = true;
        direnv.enableZshIntegration = true;
        direnv.nix-direnv.enable = true;

        lf.enable = true;
        lf.commands = {
          dragon-out = ''%${pkgs.xdragon}/bin/xdragon -a -x "$fx"'';
          editor-open = ''$$EDITOR $f'';
          mkfile = ''
            ''${{
              printf "Dirname: "
              read DIR

              if [[ $DIR = */ ]]; then
                mkdir $DIR
              else
                touch $DIR
              fi
            }}'';
        };
        lf.extraConfig = let
          previewer = pkgs.writeShellScriptBin "pv.sh" ''
            file=$1
            w=$2
            h=$3
            x=$4
            y=$5

            if [[ "$(${pkgs.file}/bin/file -Lb --mime-type "$file")" =~ ^image ]]; then
              ${pkgs.kitty}/bin/kitty +kitten icat --silent --stdin no --transfer-mode file --place "''${w}x''${h}@''${x}x''${y}" "$file" < /dev/null > /dev/tty
              exit 1
            fi

            ${pkgs.pistol}/bin/pistol "$file"
          '';
          cleaner = pkgs.writeShellScriptBin "clean.sh" ''
            ${pkgs.kitty}/bin/kitty +kitten icat --clear --stdin no --silent --transfer-mode file < /dev/null > /dev/tty
          '';
        in
          mkDefault ''
            set cleaner ${cleaner}/bin/clean.sh
            set previewer ${previewer}/bin/pv.sh
          '';

        neovim.enable = true;

        starship.enable = true;
        starship.enableZshIntegration = true;

        tmux.baseIndex = 1;
        tmux.enable = true;
        tmux.extraConfig = ''
          set -sg terminal-overrides ",*:RGB"

          set -g renumber-windows on

          bind -T prefix / split-window -v -c "#''''{pane_current_path}"
          bind -T prefix \\ split-window -h -c "#''''{pane_current_path}"

          ${
            if cfg.sessionizer.enable
            then "bind -T prefix g run-shell \"tmux neww ${sessionizer}/bin/sessionizer\""
            else ""
          }
        '';
        tmux.keyMode = "vi";
        tmux.newSession = true;
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
          {
            plugin = tmuxPlugins.resurrect;
            extraConfig = ''
              set -g @resurrect-strategy-nvim 'session'
            '';
          }
          {
            plugin = tmuxPlugins.continuum;
            extraConfig = ''
              set -g @continuum-boot 'on'
            '';
          }
        ];
        tmux.shell = cfg.shell.bin;
        tmux.terminal = "screen-256color";

        alacritty = {
          enable = mkDefault true;
          settings = {
            shell.program = cfg.shell.bin;
            shell.args = cfg.shell.defaultArgs;
            window = {
              padding.x = 5;
              padding.y = 5;
            };
            font = {
              normal = {
                family = "FiraCode Nerd Font";
                style = "Regular";
              };
              size = 10;
            };
          };
        };

        zsh.enable = true;
        zsh.autosuggestion.enable = true;
        zsh.enableCompletion = true;
        zsh.initExtra = ''
          export GPG_TTY=$(tty)

          alias tmux="tmux -f ${config.xdg.configHome}/tmux/tmux.conf";
          alias lg="${pkgs.lazygit}/bin/lazygit";
          alias goto="${sessionizer}/bin/sessionizer"
          alias gt="${sessionizer}/bin/sessionizer"
        '';
      };
    };
}
