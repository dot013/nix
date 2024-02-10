{ ... }:

{
  imports = [
    ../shared-home.nix
  ];
  options.default.home = { };
  config = {
    librewolf.profiles.guz.isDefault = true;

    services.flatpak.packages = [
      "com.valvesoftware.Steam"
    ];
  };
}
