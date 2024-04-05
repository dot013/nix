# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, ... }:

{
  imports = [
    ../../modules/nixos/config/host.nix
    ../../modules/nih
    ./hardware-configuration.nix
  ];

  nih = {
    enable = true;
    name = "homelab";
    ip = "192.168.1.10";
    type = "server";

    networking = {
      interface = "eno1";
      wireless = false;
    };

    services.tailscale = {
      enable = true;
      exitNode = true;
      routingFeatures = "both";
    };

    users.guz = {
      username = "guz";
      password = "$y$j9T$J7gmdB306rufrjdsY5kJq0$spluDZf8jEkG0VYcZXzBIpnACVIk27C8YTbo2vbNFfA";

      profiles.gterminal.enable = true;
    };
  };


  /*
      server = {
      enable = true;
      flakeDir = "/home/guz/.nix#homelab";
      name = "homelab";
      domain = "homelab.local";

      ip = "100.66.139.89";
      localIp = "192.168.1.10";

      network = {
      enable = true;
      interface = "eno1";
      };

      nextcloud = {
      enable = true;
      settings.admin = {
        passwordFile = /. + config.sops.secrets."nextcloud/user1/password".path;
      };
      };

      tailscale = {
      enable = true;
      mode = "both";
      exitNode = true;
      };

      forgejo = {
      enable = true;
      actions = {
      enable = true;
      runnerToken = "PYKxHNpeCR2ajtdPgo1C3rvgZHNJqzH4bUXLDwLa";
      };
      settings.server.url = "https://${config.server.forgejo.settings.server.domain}";
      settings.users."user1" = {
      name = /. + config.sops.secrets."forgejo/user1/name".path;
      email = /. + config.sops.secrets."forgejo/user1/email".path;
      password = /. + config.sops.secrets."forgejo/user1/password".path;
      admin = true;
      };
      settings.ui.themes = [ "forgejo-dark" "arc-green" ];
       I'm hours trying to make pushing via SSH work, but using the {user}@{domain}:{owner}/{repo}
       simply isn't working and returns "does not appear to be a git repository". Probably
       is a problem with all the "domain handling" stuff with caddy, adguard, etc. This is
       a temporary fix, so I don't end up breaking my actual sanity.
      settings.security.allowBypassGiteaEnv = true;
      };

      jellyfin = {
      enable = true;
      };
      };
    */
  services.tailscale.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}


