{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
    ../../modules/nixos/config/host.nix
    ../../modules/nixos/systems/set-user.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  sops.defaultSopsFile = ../../secrets/desktop-secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/guz/.config/sops/age/keys.txt";

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [
    kitty
    rofi-wayland
    dunst
    libnotify
    swww
    sops
    wl-clipboard
  ];

  hardware = {
    opengl.enable = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  programs.zsh.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.

  services.flatpak.enable = true;

  environment.pathsToLink = [ " /share/zsh " ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;


}


