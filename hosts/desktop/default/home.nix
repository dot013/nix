{ ... }:

{
  imports = [
    ../shared-home.nix
  ];
  options.default.home = { };
  config = {
    librewolf.profiles.guz.isDefault = true;
  };
}
