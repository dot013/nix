{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tmux;
in {
  imports = [];
  options.tmux = with lib;
  with lib.types; {
    enable = mkEnableOption "Enable Tmux module";
    baseIndex = mkOption {
      type = ints.unsigned;
      default = 1;
    };
    prefix = mkOption {
      type = str;
      default = "C-Space";
    };
    shell = mkOption {
      type = str;
      default = "\${pkgs.bash}/bin/bash";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.tmux.enable = true;

    programs.tmux.baseIndex = cfg.baseIndex;

    programs.tmux.keyMode = "vi";

    programs.tmux.mouse = true;

    programs.tmux.terminal = "screen-256color";

    programs.tmux.prefix = cfg.prefix;

    # TODO: package tmux plugins so tpm is not necessary
    home.file."${config.xdg.configHome}/tmux/plugins/tpm" = {
      source = inputs.tmux-plugin-manager;
    };

    home.packages = with pkgs; [
      entr # b0o/tmux-autoreload depends on it
    ];

    programs.tmux.extraConfig = ''
      set -g @plugin 'b0o/tmux-autoreload'
      set -g @plugin 'aserowy/tmux.nvim'
      set -g @plugin 'guz013/frappuccino-tmux'
      set -g @plugin 'pschmitt/tmux-ssh-split'

      set -sg terminal-overrides ",*:RGB"

      set -g renumber-windows on

      bind -T prefix / split-window -v -c "#''''{pane_current_path}"
      bind -T prefix \\ split-window -h -c "#''''{pane_current_path}"

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

      run '${config.xdg.configHome}/tmux/plugins/tpm/tpm'
    '';
  };
}
