{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}:
with lib; let
  cfg = config.services.minecraft-servers;
  inherit (inputs.nix-minecraft.lib) collectFilesAt;
in {
  imports = [
    self.nixosModules.playit
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  services.playit.enable = true;
  services.playit.secretPath = config.sops.secrets."services/minecraft/playit-secret".path;

  services.minecraft-servers.enable = true;
  services.minecraft-servers.eula = true;
  services.minecraft-servers.dataDir = "/var/lib/minecraft-servers";
  services.minecraft-servers.managementSystem = {
    tmux.enable = false;
    systemd-socket.enable = true;
  };
  services.minecraft-servers.openFirewall = true;

  services.minecraft-servers.servers = let
    velocityToml = cfg.servers."proxy".files."velocity.toml".value;
  in {
    "proxy" = {
      enable = true;
      enableReload = true;
      autoStart = true;
      stopCommand = "end";
      files = {
        "velocity.toml".value =
          (importTOML (pkgs.fetchurl {
            url = "https://github.com/PaperMC/Velocity/raw/refs/heads/dev/3.0.0/proxy/src/main/resources/default-velocity.toml";
            hash = "sha256-bymzTBLn4rRajUWg74NE7i0nVY2ezTqzBaDq+iaQPR4=";
          }))
          // {
            advanced = {
              haproxy-protocol = true;
              show-ping-requests = true;
              tcp-fast-open = true;
            };
            bind = "0.0.0.0:25565";
            forced-hosts = {};
            online-mode = true;
            player-info-forwarding-mode = "modern";
            ping-passthrough = "description";
            servers = {
              favelasmp = "127.0.0.1:30066";
              try = ["favelasmp"];
            };
            show-max-players = 13;
          };
      };
      symlinks = {
        "forwarding.secret" =
          config.sops.secrets."services/minecraft/proxy-secret".path;
        "plugins/global-whitelist-1.0.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/aKrMZ5cC/versions/5GDSLhSp/global-whitelist-1.0.jar";
          sha512 = "908599f3674a93bc15b47caba3a22ffc12c0ecaa82b07ea3bc348a9466383b42af77dba9d23ec0af32f0639c3bcc061d366edb3d51eb2df58d95f9107fe4bc0c";
        };
        "plugins/global-whitelist/whitelist.json" =
          config.sops.secrets."services/minecraft/favelasmp-whitelist".path;
        "plugins/limited-offline-mode-1.2.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/cyWe0UpE/versions/39AVRi1e/limited-offline-mode-1.2.jar";
          sha512 = "bef617152931885b8a23c8e668e6a179d21c28fc27ecae1212ea6fbfcfc583db4c62f4f3bdd5c523dae6c5a12d18e4e709a24eadb8ac088979def530f8f824f3";
        };
        "plugins/limited-offline-mode/allowed-users.txt" =
          config.sops.secrets."services/minecraft/proxy-allowed-users".path;
        "plugins/Geyser-Velocity.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/wKkoqHrH/versions/x7XpMAYg/Geyser-Velocity.jar";
          sha512 = "f497488eb730202d492a3a80788dfb1389b1a75459df4c258e1620f0655cef85dc58ce589b41cb9ff5b937cda18a2b1416348ce4bb59db2089b539a306289223";
        };
        "plugins/Geyser-Velocity/config.yml" =
          config.sops.secrets."services/minecraft/proxy-geyser-config".path;
        "plugins/floodgate-velocity.jar" = pkgs.fetchurl {
          url = "https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/velocity";
          hash = "sha256-8liZUEOkhpy28e9gURCsHZBmpbHhsxZJWiWwavoMEGA=";
        };
        "plugins/ViaVersion-5.9.2-SNAPSHOT.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/P1OZGk5p/versions/LXloXgE7/ViaVersion-5.9.2-SNAPSHOT.jar";
          sha512 = "55f6095de22481a0230e1cc419f333349156322924b9d5476cb4d4becc919cc6c522312ad325906a7e724fe45d68dee4cb938622285cf6d9ba5645e486f0b3ea";
        };
        "plugins/ViaBackwards-5.9.2-SNAPSHOT.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/NpvuJQoq/versions/an2egx81/ViaBackwards-5.9.2-SNAPSHOT.jar";
          sha512 = "94d0960df54cf351cfe20efb05d540b6600a53dc07456425199034f2228c59d7a97216f7a562202915ee08cc1c86d751e3ca8e98696b989fcbca985478de933c";
        };
        "plugins/ViaRewind-4.1.1.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/TbHIxhx5/versions/cOg14EE7/ViaRewind-4.1.1.jar";
          sha512 = "1c1f4db775d9dfbe288776bdbd2e0b2f4910643b9034607d813ee509da25fc45e84cfb0183cdfc30560b2632f24c75dcc51a4a9bb0de8ff29ac9e24bd89efc94";
        };
        "plugins/voicechat-velocity-2.6.13.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/5SU8XYFw/voicechat-velocity-2.6.13.jar";
          sha512 = "1096d733949b5743ba4af83fd8648caa738ebbeeb9427427f46949c7f33f812aeb914422268f96a1f4c5cccd9e9187426015db6ea000c472a71d237555c17e28";
        };
        "plugins/voicechat/voicechat-proxy.properties" =
          config.sops.secrets."services/minecraft/proxy-voicechat-properties".path;
      };
      jvmOpts = join " " [
        "-Xms1G"
        "-Xmx1G"
        "-XX:+UseG1GC"
        "-XX:G1HeapRegionSize=4M"
        "-XX:+UnlockExperimentalVMOptions"
        "-XX:+ParallelRefProcEnabled"
        "-XX:+AlwaysPreTouch"
        "-XX:MaxInlineLevel=15"
      ];
      package = pkgs.velocityServers.velocity.override {
        url = "https://fill-data.papermc.io/v1/objects/88bc3a05a10f1031e007969d78f7b4f8c78722bb0c4633425e823e1e11928b04/velocity-3.5.0-SNAPSHOT-595.jar";
        sha256 = "88bc3a05a10f1031e007969d78f7b4f8c78722bb0c4633425e823e1e11928b04";
        jre_headless = pkgs.jdk25_headless;
      };
    };
    "favelasmp" = let
      modpack = inputs.favelasmp.packages.${pkgs.stdenv.hostPlatform.system}.modpack;
      mcVersion = modpack.manifest.versions.minecraft;
      fabricVersion = modpack.manifest.versions.fabric;
    in rec {
      enable = true;
      enableReload = true;
      extraReload =
        pipe ''
          /bluemap reload light
          /reload
        '' [
          (splitString "\n")
          (filter (l: hasPrefix "/" l))
          (map (c: "echo '${c}' > ${cfg.runDir}/favelasmp.stdin"))
          (join "\n")
        ];
      autoStart = true;
      jvmOpts = join " " [
        "-Xms2G"
        "-Xmx2G"
        "-XX:+UseG1GC"
        "-XX:+UnlockExperimentalVMOptions"
        "-XX:MaxGCPauseMillis=100"
        "-XX:+DisableExplicitGC"
        "-XX:TargetSurvivorRatio=90"
        "-XX:G1NewSizePercent=50"
        "-XX:G1MaxNewSizePercent=80"
        "-XX:G1MixedGCLiveThresholdPercent=50"
        "-XX:+AlwaysPreTouch"
      ];
      package = pkgs.fabricServers."fabric-${replaceStrings ["."] ["_"] mcVersion}".override {
        jre_headless = pkgs.jdk25_headless;
        loaderVersion = fabricVersion;
      };
      managementSystem.systemd-socket.enable = true;
      symlinks =
        collectFilesAt modpack "mods"
        // {
          "mods/bluemap-5.20-fabric.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/swbUV1cr/versions/D9j76thC/bluemap-5.20-fabric.jar";
            sha512 = "b140390c505655491130f74653fc0e9cd9501f35f001c174965c13bccf45bb91900c4ed439ecdb8d824723fb57688a20ce37582b7b3a4a04623af09854f6fb2d";
          };
          "mods/fabric-api-0.149.0+26.1.2.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/Sy2Bq7Xc/fabric-api-0.149.0%2B26.1.2.jar";
            sha512 = "c7589aa4deeaa6dbefc13247eb5e0d4e257c152ef039937f54d6ee28282d3c84ccc96483d9c3950286fed6e3dcc546709898c8a446ab143d1663bc7d49649c54";
          };
          "mods/FabricProxy-Lite-2.12.0.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/8dI2tmqs/versions/CsEpiziv/FabricProxy-Lite-2.12.0.jar";
            sha512 = "b479c3ed1fe83929cad40e5c925ae2702da879b88a0271a24266cd21ecc037953f347cbe61ac7b7334e087544ee2ce5bf1f041fc3e64f50474404ad564c146f7";
          };
          "mods/Floodgate-Fabric-2.2.6-b63.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/bWrNNfkb/versions/fD4J9lnX/Floodgate-Fabric-2.2.6-b63.jar";
            sha512 = "54874033236df688da15fd4dd7d2d99d002e8955cb2d788d5ba409d753eb17629f53a6e976992de8cca8c8dd3663c70b283da88b5a12d72cef9647d09e04ae62";
          };
          "mods/git-pack-manager-fabric-26.1-5.2.1+fabric+26.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/PV38O99l/versions/LmejPXPp/git-pack-manager-fabric-26.1-5.2.1%2Bfabric%2B26.1.jar";
            sha512 = "d87dadc0e6cff7126ea79acbcaf7df623c04c50edb7611672ad0e4802bae70e6046b428c87dce82c850354029887510c9e308a546df88cbc69567ca13b2a588f";
          };
          "mods/mc2discord-fabric-26.1-4.2.7.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/Cfbcv7uF/versions/gZNbQZKq/mc2discord-fabric-26.1-4.2.7.jar";
            sha512 = "dd4dc476e835d9346482f8e64d2cbca7e1e868685162a038647d157beb6dab58c35ad31c041d4e0e3bb548e7c8e6008b181f07fa87dc69c547833539a0ab03f1";
          };
          "mods/mesh-lib-fabric-26.1-2.0.4+fabric+26.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/6HncyfPB/versions/wIXK3aQp/mesh-lib-fabric-26.1-2.0.4%2Bfabric%2B26.1.jar";
            sha512 = "55f180f4a2f2663d91a5286a4105657437ff884cf46bcc10f8d183173cc10dce3c8a7b8eb0c71d21d4d89a917b751f8a2901ddae6d061d7f53307bd6d2d2a4aa";
          };
          "mods/monkeylib538-fabric-26.1-4.0.1+fabric+26.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/gYap5A8T/versions/nRrNqvwM/monkeylib538-fabric-26.1-4.0.1%2Bfabric%2B26.1.jar";
            sha512 = "f86874822ca5aeb6c237acbe9cb54ecac78c4240204a5e632efad964f4343d94c4516ee5e45f8618593e2bce605238d75b9b3c4b3cadf012e3ad71efb91b9c91";
          };
          "mods/placeholder-api-3.0.0+26.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/eXts2L7r/versions/b3IPAHgB/placeholder-api-3.0.0%2B26.1.jar";
            sha512 = "b559da0f13fef17967f2aff1d06b00995c7db21d9d5b7b580ab6eafdf2365e4ac86a7d094c2b481160a942f291bc2595f2cb8c91ce5e169f1c2f461782ecd2a8";
          };
        };
      files = let
        createWebhook = {
          title,
          description,
          color,
        }: {
          content = null;
          embeds = [
            {
              inherit title description color;
              fields = [
                {
                  name = "{newCommitHash}";
                  value = "{longDescriptiopn}";
                }
              ];
              author = {name = "{author}";};
              footer = {text = "{timeOfCommit}";};
            }
          ];
          username = "Git Pack Manager";
          attachments = [];
        };
      in
        # (collectFilesAt modpack "config")
        # // {
        {
          "whitelist.json" =
            config.sops.secrets."services/minecraft/favelasmp-whitelist".path;
          "ops.json" =
            config.sops.secrets."services/minecraft/favelasmp-ops".path;
          "config/bluemap/core.conf" = {
            format = pkgs.formats.keyValue {};
            value = {
              accept-download = true;
              render-thread-count = 1;
              metrics = false;
            };
          };
          "config/bluemap/webserver.conf" = {
            format = pkgs.formats.keyValue {};
            value = {
              port = serverProperties.server-port + 101;
            };
          };
          "config/bluemap/webapp.conf" = {
            format = pkgs.formats.keyValue {};
            value = {
              start-location = ''"world:2213:40:2551:236:0:0:0:0:perspective"'';
            };
          };
          "config/FabricProxy-Lite.toml".value = {
            hackOnlineMode = true;
          };
          "config/git-pack-manager/main.json" =
            config.sops.secrets."services/minecraft/favelasmp-pack-manager".path;
          "config/git-pack-manager/success_resourcepack_message.json".value = createWebhook {
            title = "Resource Packs do Servidor Atualizadas";
            description = ''
              As resource packs do servidor foram atualizadas.

              Use `/git-pack-manager request-pack` para atualizarem sem precisar sair do servidor.

              Caso queiram baixar a resource pack diretamente; acesse o link:
              {downloadUrl}'';
            color = "#16d86b";
          };
          "config/mesh-lib/main.json".value = {
            httpPort = serverProperties.server-port + 100;
            exposedPort = 443;
          };
          "config/mc2discord.toml" =
            config.sops.secrets."services/minecraft/favelasmp-discord".path;
          "config/voicechat/voicechat-server.properties".value = {
            port = 24455;
          };
        };
      environment = {
        FABRIC_PROXY_SECRET_FILE = config.sops.secrets."services/minecraft/proxy-secret".path;
      };
      serverProperties = {
        allow-flight = true;
        broadcast-console-to-opts = true;
        difficulty = "normal";
        enforce-whitelist = true;
        enforce-secure-profile = false;
        gamemode = "survival";
        online-mode = true;
        maxPlayers = velocityToml.show-max-players;
        motd = "§k0§r Bem vindo a §6§lFavelaSMP! §r§k0§r";
        require-resource-pack = true;
        resource-pack-prompt = "O servidor usa uma §6resourcepack§r customizada para cosméticos e datapacks que foram adicionados no servidor. §cSem ela você não terá uma experiência completa e haverá bugs!§r";
        view-distance = 12;
        server-ip = elemAt (splitString ":" velocityToml.servers.favelasmp) 0;
        server-port = toInt (elemAt (splitString ":" velocityToml.servers.favelasmp) 1);
      };
    };
  };

  networking.firewall.allowedUDPPorts = [24454 24455];

  systemd.services = let
    tellraw = c: t: ''/tellraw @a ["",{"text":"\n"},{"text":"<FavelaSMP>","bold":true,"color":"gold"},{"text":" O servidor irá reiniciar em "},{"text":"${t}","bold":true,"color":"${c}"},{"text":".\n "}]'';
  in {
    "minecraft-servers-restart-warning-10m" = {
      script = "echo '${tellraw "yellow" "10 minutos"}' > ${cfg.runDir}/favelasmp.stdin";
      serviceConfig = {
        Type = "oneshot";
        User = "${cfg.user}";
      };
      startAt = [
        "11:50:00 ${config.time.timeZone}"
        "23:50:00 ${config.time.timeZone}"
      ];
    };
    "minecraft-servers-restart-warning-1m" = {
      script = "echo '${tellraw "red" "1 minuto"}' > ${cfg.runDir}/favelasmp.stdin";
      serviceConfig = {
        Type = "oneshot";
        User = "${cfg.user}";
      };
      startAt = [
        "11:59:00 ${config.time.timeZone}"
        "23:59:00 ${config.time.timeZone}"
      ];
    };
    "minecraft-servers-restart" = {
      script = ''
        echo '/tellraw @a ["",{"text":"\n"},{"text":"<FavelaSMP>","bold":true,"color":"gold"},{"text":" Servidor reiniciando."},{"text":".\n "}]' > ${cfg.runDir}/favelasmp.stdin

        webhook="$(cat ${config.sops.secrets."services/minecraft/discord-webhook".path})"
        data="$(printf '{
          "embeds": [
          {
            "title": "O Servidor Irá Reiniciar",
            "color": 16418816,
            "description": "O servidor irá reiniciar automaticamente para limpar a memória usada e evitar instabilidade.",
            "footer": {
            "text": "FavelaSMP"
            },
            "timestamp": "%s"
          }
          ],
          "username": "FavelaSMP"
        }' "$(date -u +%FT%TZ)")"

        ${getExe pkgs.curl} -X POST "$webhook" \
          -H "Content-Type: application/json" \
          -d "$data"

        sleep 1s

        systemctl restart minecraft-server-favelasmp.service
        systemctl restart minecraft-server-proxy.service
        systemctl restart playit.service
      '';
      serviceConfig.Type = "oneshot";
      startAt = [
        "12:00:00 ${config.time.timeZone}"
        "00:00:00 ${config.time.timeZone}"
      ];
    };
  };

  services.caddy.virtualHosts."favelasmp.guz.one:80" = let
    meshLib = cfg.servers."favelasmp".files."config/mesh-lib/main.json".value;
    bluemapServer = cfg.servers."favelasmp".files."config/bluemap/webserver.conf".value;
  in {
    extraConfig = ''
      header Content-Type text/html
      respond <<HTML
        <html>
          <head><title>FavelaSMP</title></head>
          <body><h1>Hello, FavelaSMP</h1></body>
        </html>
        HTML 200

      handle /git-pack-manager* {
        reverse_proxy http://localhost:${toString meshLib.httpPort} {
          header_up X-Real-Ip {header.Cf-Connecting-Ip}
          header_up X-Forwarded-For {header.Cf-Connecting-Ip}
          header_up X-Forwarded-Proto https
          header_up Host {host}
        }
      }

      redir /map /map/ permanent
      handle_path /map/* {
        reverse_proxy http://localhost:${toString bluemapServer.port} {
          header_up X-Real-Ip {header.Cf-Connecting-Ip}
          header_up X-Forwarded-For {header.Cf-Connecting-Ip}
          header_up X-Forwarded-Proto https
          header_up Host {host}
        }
      }
    '';
  };

  environment.persistence."/persist".directories = [
    cfg.dataDir
  ];

  nixpkgs.overlays = [
    inputs.nix-minecraft.overlay
  ];
  nixpkgs.config.allowUnfree = true;
  nix.allowUnfreeList = [
    "minecraft-server"
    "minecraft-server-21.1.2"
  ];

  sops.secrets = {
    "services/minecraft/discord-webhook" = {};
    "services/minecraft/playit-secret" = {};
    "services/minecraft/proxy-allowed-users".owner = config.services.minecraft-servers.user;
    "services/minecraft/proxy-geyser-config".owner = config.services.minecraft-servers.user;
    "services/minecraft/proxy-secret".owner = config.services.minecraft-servers.user;
    "services/minecraft/proxy-voicechat-properties".owner = config.services.minecraft-servers.user;
    "services/minecraft/favelasmp-discord".owner = config.services.minecraft-servers.user;
    "services/minecraft/favelasmp-pack-manager".owner = config.services.minecraft-servers.user;
    "services/minecraft/favelasmp-ops".owner = config.services.minecraft-servers.user;
    "services/minecraft/favelasmp-voicechat-properties".owner = config.services.minecraft-servers.user;
    "services/minecraft/favelasmp-whitelist".owner = config.services.minecraft-servers.user;
  };
}
