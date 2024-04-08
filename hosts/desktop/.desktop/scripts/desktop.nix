{pkgs, ...}: let
  desktop = pkgs.writeShellScriptBin "desktop" ''
    function cat() {
      echo $1 | ${pkgs.lolcat}/bin/lolcat
      echo ""
    }
    flakeDir="/home/guz/.nix"

    function nix-build() {
      local env="$2"

      if [[ "$env" -ne "" ]]; then
        cat "Building the $env desktop!"
        sudo nixos-rebuild switch --flake "$flakeDir#desktop@$env"
      else
        cat "Building the desktop!"
        sudo nixos-rebuild switch --flake "$flakeDir#desktop@default"
      fi
    }

    # command for switching desktop environments/modes
    function desktop-switch() {
      local env="$1"

      if [[ "$env" == "--build" ]]; then
        nix-build $env $2
      else
        cat "Switching to $1 desktop!"

        # this will be used a lot, that's why "test" and --fast is passed
        # for building to a new configuration, use nix-build instead
        sudo nixos-rebuild test --fast --flake "$flakeDir#desktop@$env"
      fi
    }
    desktop-switch $1 $2

    # echo "Restarting services (just in case)" # why? Because discord, as always
    # systemctl --user stop xdg-desktop-portal-hyprland.service xdg-desktop-portal.service pipewire.service
    # systemctl --user start xdg-desktop-portal-hyprland.service xdg-desktop-portal.service pipewire.service

    echo ""
    cat "Done!"

    echo "Restarting zsh"
    exec zsh
  '';
in {
  imports = [];
  options.desktop.cli = {};
  config = {
    home.packages = [
      desktop
    ];
  };
}
