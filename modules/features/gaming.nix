{
  nixos = {...}: {
    programs.steam.enable = true;
    programs.gamemode.enable = true;
    programs.gamemode.enableRenice = true;

    hardware.steam-hardware.enable = true;

    nix.allowUnfreeList = ["steam" "steam-unwrapped"];
  };
  homeManager = {
    osConfig,
    pkgs,
    ...
  }: {
    # Lutris
    programs.lutris.enable = true;
    programs.lutris.steamPackage = osConfig.programs.steam.package;
    programs.lutris.extraPackages = with pkgs; [libunwind gamemode mangohud];
    programs.lutris.protonPackages = with pkgs; [proton-ge-bin];
    programs.lutris.winePackages = with pkgs; [wine wineWow64Packages.full];

    services.flatpak.packages = ["org.vinegarhq.Sober"];
  };
}
