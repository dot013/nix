{ config, pkgs, inputs, ... }:


{
  imports = [ ];

  programs.zsh.enable = true;

  set-user.users = [{
    username = "guz";
    shell = pkgs.zsh;
    home = {
      imports = [
        ../../../modules/home-manager/programs/starship.nix
        ../../../modules/home-manager/programs/tmux.nix
        ../../../modules/home-manager/programs/zsh.nix
        ../../../modules/home-manager/packages/nixi.nix
        ../../../modules/home-manager/packages/nixx.nix
      ];

      starship.enable = true;
      starship.enableZsh = true;

      tmux.enable = true;
      tmux.shell = "\${pkgs.zsh}/bin/zsh";

      zsh.enable = true;
      zsh.extraConfig.init = ''
        export GPG_TTY=$(tty)

        alias tmux="tmux -f /home/guz/.config/tmux/tmux.conf"
      '';
    };
  }];
}
