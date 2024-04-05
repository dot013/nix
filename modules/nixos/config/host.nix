# Config shared between all host's configuration.nix (NixOS config)
{ config, pkgs, inputs, lib, ... }:

let
  cfg = config.host;
in
{
  imports = [
    inputs.home-manager.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    ../systems/localization.nix
  ];
  options.host = with lib; with lib.types; {
    networking = {
      hostName = mkOption {
        default = "nixos";
        type = str;
        description = "Define the host's network name";
      };
      wireless.enable = mkOption {
        default = false;
        type = bool;
        description = "Enables wireless support";
      };
    };
    time = {
      timeZone = mkOption {
        type = str;
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

      hostName = lib.mkDefault cfg.networking.hostName;
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
      wireplumber.enable = true;
      #jack.enable = true;
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      vim
      neovim
      tmux
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
