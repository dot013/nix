{
  nixos = {...}: {
    services.flatpak.enable = true;
  };
  homeManager = {inputs, ...}: {
    imports = [
      inputs.nix-flatpak.homeManagerModules.nix-flatpak
    ];
    services.flatpak.enable = true;
  };
}
