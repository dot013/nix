{ config, lib, pkgs, ... }:

let
  cfg = config.nih;
  applyAttrNames = builtins.mapAttrs (name: f: f name);
in
{
  imports = [
    ./sound.nix
    ./users.nix
    ./networking
    ./services
  ];
  options.nih = with lib; with lib.types; {
    domain = mkOption {
      type = str;
      default = "${cfg.name}.local";
    };
    enable = mkEnableOption "";
    flakeDir = mkOption {
      type = either str path;
    };
    handleDomains = mkOption {
      type = bool;
      default = true;
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
  };
  config = with lib; mkIf cfg.enable {
    boot = {
      loader.systemd-boot.enable = mkDefault true;
      loader.efi.canTouchEfiVariables = mkDefault true;
    };

    systemd.services."nih-setup" = with builtins; {
      script = ''
        echo ${builtins.toJSON cfg.users}
      '';
      wantedBy = [ "multi-user.target" ];
      after = [ "forgejo.service" ];
      serviceConfig = {
        Type = "oneshot";
      };
    };

    # Handle domains configuration

    networking.firewall.allowedTCPPorts = mkIf cfg.handleDomains [ 80 433 ];

    systemd.services."tailscaled" = mkIf cfg.handleDomains {
      serviceConfig = {
        Environment = [ "TS_PERMIT_CERT_UID=caddy" ];
      };
    };

    nih.services = mkIf cfg.handleDomains {
      adguard = {
        enable = true;
        settings.dns.rewrites = (if hasPrefix "*." cfg.domain then {
          "${cfg.domain}" = cfg.ip;
        } else {
          "${cfg.domain}" = cfg.ip;
          "${"*." + cfg.domain}" = cfg.ip;
        });
      };

      caddy =
        let
          nihServices = (filterAttrs (n: v: builtins.isAttrs v && v?domain) cfg.services);
        in
        mkIf cfg.handleDomains {
          enable = true;
          virtualHosts = mapAttrs'
            (name: value: nameValuePair (value.domain) ({
              extraConfig = ''
                reverse_proxy ${cfg.localIp}:${toString value.port}
              '';
            }))
            nihServices;
        };
    };
  };
}
