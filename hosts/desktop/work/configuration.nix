{ pkgs, ... }:

{
  imports = [
    ../shared-configuration.nix
  ];
  options.work.configuration = { };
  config = {
    set-user.users = [
      {
        username = "guz";
        shell = pkgs.zsh;
        home = import ./home.nix;
      }
    ];
  };
}
