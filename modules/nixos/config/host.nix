# Config shared between all host's configuration.nix (NixOS config)
{ config, pkgs, inputs, lib, ... }:

let
  cfg = config.host;
in
{
  imports = [
    inputs.home-manager.nixosModules.default
    ../systems/localization.nix
  ];
  options.host = {
    networking = {
      hostName = lib.mkOption {
        default = "nixos";
        type = lib.types.str;
        description = "Define the host's network name";
      };
      wireless.enable = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = "Enables wireless support";
      };
    };
    time = {
      timeZone = lib.mkOption {
        type = lib.types.str;
        description = "Sets host's time zone";
      };
    };
  };
  config = {
    # Nix configuration 
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    boot = {
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
    };

    networking = {
      networkmanager.enable = true;

      hostName = cfg.networking.hostName;
      wireless.enable = cfg.networking.wireless.enable;

      # Configure network proxy if necessary
      # proxy.default = "http://user:password@proxy:port/";
      # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
    };

    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      #jack.enable = true;
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      vim
      neovim
      git
      lazygit
      gcc # Added temporally so my neovim config doesn't break
      wget
      nixpkgs-fmt
      nixpkgs-lint
    ];
    environment.sessionVariables = {
      EDITOR = "nvim";
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.11"; # Did you read the comment?

  };
}
