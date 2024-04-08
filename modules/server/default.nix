{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.server;
  server = pkgs.writeShellScriptBin "server" ''
    gum="${pkgs.gum}/bin/gum";
    flakeDir="${toString cfg.flakeDir}";

    command="$1";

    if [[ "$command" == "build" ]]; then
      shift 1;
      sudo nixos-rebuild switch --flake "$flakeDir" "$@"
    fi

    ${
      if cfg.forgejo.cliAlias
      then ''
        if [[ "$command" == "forgejo" ]]; then
          shift 1;
          sudo --user=${cfg.forgejo.user} ${cfg.forgejo.package}/bin/gitea --work-path ${cfg.forgejo.data.root} "$@"
        fi

        if [[ "$command" == "forgejo-act" ]]; then
          shift 1;
          sudo --user=${cfg.forgejo.user} ${cfg.forgejo.actions.package}/bin/act_runner --config /var/lib/gitea-runner/${cfg.forgejo.actions.instanceName} "$@"
        fi
      ''
      else ""
    }
  '';
in {
  imports = [
    ./adguard.nix
    ./caddy.nix
    ./forgejo.nix
    ./jellyfin.nix
    ./jellyseerr.nix
    ./network.nix
    ./nextcloud.nix
    ./photoprism.nix
    ./tailscale.nix
  ];
  options.server = with lib;
  with lib.types; {
    enable = mkEnableOption "";
    name = mkOption {
      type = str;
      default = "server";
    };
    flakeDir = mkOption {
      type = str;
    };
    storage = mkOption {
      type = path;
      default = /data + "/${cfg.name}";
      description = "The Homelab central storage path";
    };
    domain = mkOption {
      type = either str path;
      default = "${cfg.name}.local";
    };
    localIp = mkOption {
      type = str;
    };
    ip = mkOption {
      type = str;
      default = cfg.localIp;
    };
    handleDomains = mkOption {
      type = bool;
      default = true;
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      server
    ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.handleDomains [80 433];

    systemd.services."tailscaled" = lib.mkIf cfg.handleDomains {
      serviceConfig = {
        Environment = ["TS_PERMIT_CERT_UID=caddy"];
      };
    };

    server = with lib;
      mkIf cfg.handleDomains {
        adguard = {
          enable = true;
          settings.dns.rewrites =
            if hasPrefix "*." cfg.domain
            then {
              "${cfg.domain}" = cfg.ip;
            }
            else {
              "${cfg.domain}" = cfg.ip;
              "${"*." + cfg.domain}" = cfg.ip;
            };
        };

        caddy = let
          homelabServices = lib.filterAttrs (n: v: builtins.isAttrs v && v ? domain) cfg;
        in
          with lib;
            mkIf cfg.handleDomains {
              enable = true;
              settings.virtualHosts =
                mapAttrs'
                (name: value:
                  nameValuePair (value.domain) {
                    extraConfig = ''
                      reverse_proxy ${cfg.localIp}:${toString value.port}
                    '';
                  })
                homelabServices;
            };
      };
  };
}
