{ config, lib, pkgs, ... }:

let
  cfg = config.homelab.forgejo;
in
{
  imports = [ ];
  options.homelab.forgejo = with lib; with lib.types; {
    enable = mkEnableOption "";
    user = mkOption {
      type = str;
      default = "forgejo";
    };
    data = {
      root = mkOption {
        type = path;
        default = config.homelab.storage + /forgejo;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      user = cfg.user;
      group = cfg.user;
      stateDir = toString cfg.data.root;
      database = {
        user = cfg.user;
        type = "sqlite3";
      };
    };
  };
}
