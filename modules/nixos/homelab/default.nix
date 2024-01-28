{ config, pkgs, lib, ... }:

let
  cfg = config.homelab;
  homelab = pkgs.writeShellScriptBin "homelab" ''
    gum="${pkgs.gum}/bin/gum";
    flakeDir="${toString cfg.flakeDir}";

    command="$1";

    if [[ "$command" == "build" ]]; then
      shift 1;
      sudo nixos-rebuild switch --flake "$flakeDir" "$@"
    fi

    ${if cfg.forgejo.cliAlias then ''
      if [[ "$command" == "forgejo" ]]; then
        shift 1;
        sudo --user=${cfg.forgejo.user} ${cfg.forgejo.package}/bin/gitea --work-path ${cfg.forgejo.data.root} "$@"
      fi
    '' else ""}
  '';
in
{
  imports = [
    ./adguard.nix
    ./caddy.nix
    ./forgejo.nix
  ];
  options.homelab = with lib; with lib.types; {
    enable = mkEnableOption "";
    flakeDir = mkOption {
      type = str;
    };
    storage = mkOption {
      type = path;
      default = /data/homelab;
      description = "The Homelab central storage path";
    };
    domain = mkOption {
      type = either str path;
      default = "homelab.local";
    };
    ip = mkOption {
      type = str;
    };
    localIp = mkOption {
      type = str;
    };
    handleDomains = mkOption {
      type = bool;
      default = true;
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      homelab
    ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.handleDomains [ 80 433 ];

    systemd.services."tailscaled" = lib.mkIf cfg.handleDomains {
      serviceConfig = {
        Environment = [ "TS_PERMIT_CERT_UID=caddy" ];
      };
    };

    homelab = with lib; mkIf cfg.handleDomains {
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
          homelabServices = (lib.filterAttrs (n: v: builtins.isAttrs v && v?domain) cfg);
        in
        with lib;
        mkIf cfg.handleDomains {
          enable = true;
          settings.virtualHosts = mapAttrs'
            (name: value: nameValuePair (value.domain) ({
              extraConfig = ''
                reverse_proxy ${cfg.localIp}:${toString value.port}
              '';
            }))
            homelabServices;
        };
    };
  };
}


