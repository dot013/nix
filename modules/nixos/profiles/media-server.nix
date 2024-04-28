{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.profiles.media-server;
in
{
  options.profiles.media-server = with lib;
    with lib.types; {
      enable = mkEnableOption "";
      mediaDir = mkOption {
        type = path;
        default = "/data/media";
      };
    };
  config = with lib;
    mkIf cfg.enable {
      services = {
        jellyfin.enable = mkDefault true;
        jellyfin.openFirewall = true;
        jellyseerr.enable = mkDefault true;
        prowlarr.enable = mkDefault true;
        radarr.enable = mkDefault true;
        sonarr.enable = mkDefault true;
        qbittorrent.enable = mkDefault true;
      };

      systemd.services.media-server-setup = {
        script =
          let
            services = config.services;
          in
          ''
            function setfacl() { ${pkgs.acl}/bin/setfacl "$@"; }

            echo 'Creating ${toString cfg.mediaDir} folder'
            mkdir -p ${toString cfg.mediaDir}
            mkdir -p ${toString cfg.mediaDir + "/Downloads"}
            mkdir -p ${toString cfg.mediaDir + "/Movies"}
            mkdir -p ${toString cfg.mediaDir + "/Shows"}

            ${
              if services.jellyfin.enable
              then ''
                echo 'Giving read-write permission to ${services.jellyfin.user} on ${toString cfg.mediaDir}'
                setfacl -R -m u:${services.jellyfin.user}:rwx ${toString cfg.mediaDir}
              ''
              else ""
            }
            ${
              if services.radarr.enable
              then ''
                echo 'Giving read-write permission to ${services.radarr.user} on ${toString cfg.mediaDir}'
                setfacl -R -m u:${services.radarr.user}:rwx ${toString cfg.mediaDir}
              ''
              else ""
            }
            ${
              if services.sonarr.enable
              then ''
                echo 'Giving read-write permission to ${services.sonarr.user} on ${toString cfg.mediaDir}'
                setfacl -R -m u:${services.sonarr.user}:rwx ${toString cfg.mediaDir}
              ''
              else ""
            }
            ${
              if services.qbittorrent.enable
              then ''
                echo 'Giving read-write permission to ${services.qbittorrent.user} on ${toString cfg.mediaDir}'
                setfacl -R -m u:${services.qbittorrent.user}:rwx ${toString cfg.mediaDir}
              ''
              else ""
            }

          '';
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
        };
      };
    };
}
