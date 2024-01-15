{ pkgs, ... }:

let
  desktop = pkgs.writeShellScriptBin "desktop" '' 
    function cat() {
      echo $1 | ${pkgs.lolcat}/bin/lolcat
      echo ""
    }
    flakeDir="/home/guz"

    function nix-build() {
      local env="$2"

      if [[ "$env" -ne "" ]]; then
        cat "Building the $env desktop!"
        sudo nixos-rebuild switch --flake "$flakeDir/.nix#desktop@$env"
      else 
        cat "Building the desktop!"
        sudo nixos-rebuild switch --flake "$flakeDir/.nix#desktop@default"
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
        sudo nixos-rebuild test --fast --flake "$flakeDir/.nix#desktop@$env"
      fi
    }
    desktop-switch $1 $2

    echo ""
    cat "Done!"

    echo "Restarting zsh"
    exec zsh
  '';
in
{
  home.packages = [
    desktop
  ];
}

