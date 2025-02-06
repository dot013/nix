{
  config,
  lib,
  pkgs,
  self,
  ...
}: let
  cfg = config.programs.zen-browser;
in {
  # This could be extended when https://github.com/NixOS/nixpkgs/issues/327982 is
  # fixed.
  # mkFirefoxModule (https://github.com/nix-community/home-manager/blob/f99c704fe3a4cf8d72b2d568ec80bc38be1a9407/modules/programs/firefox/mkFirefoxModule.nix)
  # can be used to create a module that handles extensions just like firefox and librewolf
  # modules.
  options.programs.zen-browser = with lib; {
    enable = mkEnableOption "";
    package = mkOption {
      type = with types; package;
      default = self.packages.${pkgs.system}.zen-browser;
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];
  };
}
