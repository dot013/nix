{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.services.minecraft-servers;
in {
  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];
  options.services.minecraft-servers = with lib; with lib.types; {};
  config = with lib;
    mkIf cfg.enable {
      nixpkgs.overlays = [inputs.nix-minecraft.overlay];
    };
}
