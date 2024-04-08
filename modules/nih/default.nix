{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.nih;
in {
  imports = [
    ./domains
    ./networking
    ./services
    ./sound.nix
    ./users.nix
  ];
  options.nih = with lib;
  with lib.types; {
    domain = mkOption {
      type = str;
      default = "${cfg.name}.local";
    };
    enable = mkEnableOption "";
    flakeDir = mkOption {
      type = either str path;
    };
    ip = mkOption {
      type = str;
    };
    localIp = mkOption {
      type = str;
      default = cfg.ip;
    };
    name = mkOption {
      type = str;
      default = "nih";
    };
    type = mkOption {
      type = enum ["laptop" "desktop" "server"];
      default = "desktop";
    };
    _nih = mkOption {
      type = attrsOf anything;
      default = with builtins; {
        servicesNamesList = readDir ./services;
      };
    };
  };
  config = with lib;
    mkIf cfg.enable {
      boot = {
        loader.systemd-boot.enable = mkDefault true;
        loader.efi.canTouchEfiVariables = mkDefault true;
      };

      systemd.services."nih-setup" = with builtins; {
        script = ''
          echo ${builtins.toJSON cfg._nih.servicesNamesList}
        '';
        wantedBy = ["multi-user.target"];
        after = ["forgejo.service"];
        serviceConfig = {
          Type = "oneshot";
        };
      };

      # Handle domains configuration

      services.openssh.enable = mkDefault (
        if cfg.type == "server"
        then true
        else false
      );
    };
}
