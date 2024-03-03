# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ../../modules/nixos/systems/set-user.nix
    ../../modules/nixos/config/host.nix
    ../../modules/server
    ./hardware-configuration.nix
    ./secrets.nix
    ./users
  ];

  server = {
    enable = true;
    flakeDir = "/home/guz/.nix#homex";
    name = "homex";

    domain = "guz.local";

    ip = "100.66.139.89";
    localIp = "192.168.1.10";

    network = {
      enable = true;
      interface = "eno1";
    };

    /*
      nextcloud = {
      enable = true;
      settings.admin = {
        passwordFile = /. + config.sops.secrets."nextcloud/user1/password".path;
      };
      };
      */

    tailscale = {
      enable = true;
      mode = "both";
      exitNode = true;
    };

    forgejo = {
      enable = true;
      settings.server.url = "https://${config.server.forgejo.settings.server.domain}";
      settings.users."user1" = {
        name = /. + config.sops.secrets."forgejo/user1/name".path;
        email = /. + config.sops.secrets."forgejo/user1/email".path;
        password = /. + config.sops.secrets."forgejo/user1/password".path;
        admin = true;
      };
      settings.ui.themes = [ "forgejo-dark" "arc-green" ];
      /*
       I'm hours trying to make pushing via SSH work, but using the {user}@{domain}:{owner}/{repo}
       simply isn't working and returns "does not appear to be a git repository". Probably
       is a problem with all the "domain handling" stuff with caddy, adguard, etc. This is
       a temporary fix, so I don't end up breaking my actual sanity.
      */
      settings.security.allowBypassGiteaEnv = true;
    };

    jellyfin = {
      enable = true;
    };
  };

  services.tailscale.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

}


