{
  pkgs,
  pkgs-unstable,
  config,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  nixpkgs.overlays = [
    inputs.nix-minecraft.overlay
  ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "minecraft-server"
      "minecraft-server-1.21.8"
    ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    dataDir = "/var/lib/minecraft-servers";
    managementSystem = {
      tmux.enable = false;
      systemd-socket.enable = true;
    };
    openFirewall = true;
    servers = {
      "heart-smp" = let
        modpack = inputs.heart-modpack.packages.${pkgs.system}.default;
        mcVersion = modpack.manifest.versions.minecraft;
        fabricVersion = modpack.manifest.versions.fabric;
        serverVersion = lib.replaceStrings ["."] ["_"] "fabric-${mcVersion}";
      in {
        enable = true;
        autoStart = false;
        package = pkgs.fabricServers.${serverVersion}.override {loaderVersion = "0.17.3";};
        symlinks = {
          "mods" = "${modpack}/mods";
        };
        files = {
          "config" = "${modpack}/config";
        };
      };
    };
  };
}
