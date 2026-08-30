{
  inputs,
  lib,
  modulesPath,
  pkgs,
  self,
  ...
}:
with lib; {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"

    self.nixosModules.features.devkit
    self.nixosModules.features.locale-brazil
    self.nixosModules.features.qmk-keyboard
    self.nixosModules.features.tailscale
  ];

  # Home Manager
  home-manager.users."guz" = {...}: {
    imports = [self.homeManagerModules.features.devkit];
    services.ollama.enable = mkForce false;
    home.stateVersion = "26.05";
  };

  # Users
  users.users."guz" = {
    extraGroups = ["wheel" "guz"];
    isNormalUser = true;
    password = "1313";
    # hashedPasswordFile = builtins.toString config.sops.secrets."guz/password".path;
    shell = self.packages.${pkgs.stdenv.hostPlatform.system}.devkit.zsh;
    packages = [
      inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko
      inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko-install
    ];
  };
  users.groups."guz" = {};

  # Network
  networking.networkmanager.enable = true;
  networking.hostName = "infiltrator";

  ## Firewall
  networking.firewall.enable = true;

  services.ollama.enable = mkForce false;

  # NH
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 3";
    flake = "/etc/nixos";
  };

  environment.etc = with lib; let
    joinPath = p: strings.normalizePath (join "/" (map (v: toString v) p));
    readRecur = p:
      pipe p [
        readDir
        (mapAttrs (n: v:
          if v != "regular"
          then readRecur (joinPath [p n])
          else v))
        (mapAttrsToList (n: v:
          if isList v
          then v
          else (joinPath [p n])))
        flatten
      ];
    listFiles = dir:
      map (p:
        pipe p [
          (splitString "/")
          (l: sublist 4 (length l) l)
          joinPath
          toString
        ]) (readRecur dir);
  in
    pipe (listFiles ../..) [
      (map (p: {
        name = "nixos/${p}";
        value = {
          mode = "0755";
          user = "root";
          group = "root";
          text = joinPath [../.. p];
        };
      }))
      listToAttrs
    ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
