{ config, lib, pkgs, ... }:

let
  cfg = config.client;
in
{
  imports = [ ];
  options.client = with lib; with lib.types; {
    enable = mkEnableOption "";
    name = mkOption {
      type = str;
      default = "client";
    };
    flakeDir = mkOption {
      type = str;
    };
    domain = mkOption {
      type = either str path;
      default = "${cfg.name}.local";
    };
    localIp = mkOption {
      type = nullOr str;
      default = null;
    };
    ip = mkOption {
      type = nullOr str;
      default = cfg.localIp;
    };
    users = mkOption {
      type = attrsOf (submodule { ... }: {
        options = { };
      });
    };
  };
  config = lib.mkIf cfg.enable { };
}
