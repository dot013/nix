{pkgs, ...}: {
  imports = [
    ../shared-configuration.nix
  ];
  options.default.configuration = {};
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
