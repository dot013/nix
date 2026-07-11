{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}:
with lib;
with builtins; let
  cfg = config.services.minecraft-servers;
  inherit (inputs.nix-minecraft.lib) collectFilesAt;

  importYAML = drv:
    fromJSON (readFile (pkgs.runCommand "from-yaml" {nativeBuildInputs = [pkgs.remarshal];}
        "remarshal -if yaml -i \"${drv}\" -of json -o \"$out\""));
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
      extraReload =
        pipe [
          "/geyser reload"
          "/globalwhitelist reload"
          "/viaversion reload"
        ] [
          (map (v: "echo '${v}' > ${cfg.runDir}/proxy.stdin"))
          (join "\n")
        ];
      autoStart = true;
      stopCommand = "end";
      files = {
        "velocity.toml".value =
          (importTOML (pkgs.fetchurl {
            url = "https://github.com/PaperMC/Velocity/raw/refs/heads/dev/3.0.0/proxy/src/main/resources/default-velocity.toml";
            hash = "sha256-WyTnwvR/JBR1ZP/cg7WTKjKzSTHli+m1N4DBpD6YWb4=";
          }))
          // {
            advanced = {
              announce-proxy-commands = true;
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
        "plugins/global-whitelist/config.properties".value = {
          enforce-whitelist = true;
          white-list = true;
        };

        "plugins/limited-offline-mode-1.2.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/cyWe0UpE/versions/39AVRi1e/limited-offline-mode-1.2.jar";
          sha512 = "bef617152931885b8a23c8e668e6a179d21c28fc27ecae1212ea6fbfcfc583db4c62f4f3bdd5c523dae6c5a12d18e4e709a24eadb8ac088979def530f8f824f3";
        };
        "plugins/limited-offline-mode/allowed-users.txt" =
          config.sops.secrets."services/minecraft/proxy-allowed-users".path;

        "plugins/Geyser-Velocity.jar" = inputs.geysermc-velocity;
        "plugins/Geyser-Velocity/config.yml" =
          config.sops.secrets."services/minecraft/proxy-geyser-config".path;

        "plugins/floodgate-velocity.jar" = inputs.floodgate-velocity;
        "plugins/floodgate/config.yml".value =
          cfg.servers."favelasmp".files."config/floodgate/config.yml".value
          // {
            send-floodgate-data = true;
          };

        "plugins/ViaVersion-5.10.1-SNAPSHOT.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/P1OZGk5p/versions/cUZ7Yg3y/ViaVersion-5.10.1-SNAPSHOT.jar";
          sha512 = "2923e378fe87026f05bff65f50bda18096af5307048f405b1a1b3bdd5c59cbf18b5b222a48ef940350f57cd124e233451b81b63d10eab728f63bec546bac0754";
        };
        "plugins/ViaBackwards-5.10.1-SNAPSHOT.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/NpvuJQoq/versions/KXqWliHi/ViaBackwards-5.10.1-SNAPSHOT.jar";
          sha512 = "b8e71a9bf651b48d69c99f5f8a81aad8d6516a021a6dc947ccbc523bbab91860afdb14a5122529dd7ed44c3270d69dd5797c800b2ed2c9a17859315737301374";
        };
        "plugins/ViaRewind-4.1.3.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/TbHIxhx5/versions/2kfqNMlc/ViaRewind-4.1.3-SNAPSHOT.jar";
          sha512 = "6c3081ea3012f1e4d0ec0650e18436ef9a615232b234c09bde00a3cb1b5674f2a73fe513bb2db2f1dc86abd879c0a7fd692671b59036968c174b2064fe4c717a";
        };

        "plugins/voicechat-velocity-2.6.18.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/ES87t4lm/voicechat-velocity-2.6.18.jar";
          sha512 = "ca8238c3f4d8c0f023912373f6dfe932961fcd83b061c70941b83cf29421d969c65d1771a4ebd7d1e5804057ae8fb92069fbc64a8e66668da119033e0e7ac3cf";
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
        "-Dvelocity.packet-decode-logging=true"
        "-Dvelocity.max-plugin-message-payload-size=1730517"
      ];
      package = pkgs.velocityServers.velocity.override {
        url = "https://fill-data.papermc.io/v1/objects/0ec616020166465dacca3b790d3db2b246f8f7c13b3aaacaae60c825744a66e0/velocity-3.5.0-SNAPSHOT-605.jar";
        sha256 = "0ec616020166465dacca3b790d3db2b246f8f7c13b3aaacaae60c825744a66e0";
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
        pipe [
          "/bluemap reload light"
          "/git-pack-manager config reload"
          "/whitelist reload"
          "/reload"
        ] [
          (map (v: "echo '${v}' > ${cfg.runDir}/favelasmp.stdin"))
          (join "\n")
        ];
      autoStart = true;
      jvmOpts = join " " [
        "-Xms4G"
        "-Xmx4G"
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
          "whitelist.json" =
            config.sops.secrets."services/minecraft/favelasmp-whitelist".path;
          "ops.json" =
            config.sops.secrets."services/minecraft/favelasmp-ops".path;
          "mods/bluemap-5.22-fabric.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/swbUV1cr/versions/VTvifNPN/bluemap-5.22-fabric.jar";
            sha512 = "ec597df7e974f1f28baa15325373442968c9643a157a6d2627cd5c36f8841c3023f2c08023d203bcfa7e0e51bce69d4623ba712babb84da73bd40f0e0c7f4dbd";
          };
          "mods/FabricProxy-Lite-2.12.0.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/8dI2tmqs/versions/CsEpiziv/FabricProxy-Lite-2.12.0.jar";
            sha512 = "b479c3ed1fe83929cad40e5c925ae2702da879b88a0271a24266cd21ecc037953f347cbe61ac7b7334e087544ee2ce5bf1f041fc3e64f50474404ad564c146f7";
          };
          # "mods/Floodgate-Fabric-2.2.6-b63.jar" = pkgs.fetchurl {
          #   url = "https://cdn.modrinth.com/data/bWrNNfkb/versions/fD4J9lnX/Floodgate-Fabric-2.2.6-b63.jar";
          #   sha512 = "54874033236df688da15fd4dd7d2d99d002e8955cb2d788d5ba409d753eb17629f53a6e976992de8cca8c8dd3663c70b283da88b5a12d72cef9647d09e04ae62";
          # };
          "mods/git-pack-manager-fabric-26.1-5.3.0+fabric+26.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/PV38O99l/versions/pvJwDlA8/git-pack-manager-fabric-26.1-5.3.0%2Bfabric%2B26.1.jar";
            sha512 = "9d0f0957f4d9c2e4cc102756327ae226adce500de9c05f2c9980a9bc27606f0c01a4e708c1694390440a4742f13129a36974bd07bdbe38c279a3396413489dfe";
          };
          "mods/mesh-lib-fabric-26.1-2.1.0+fabric+26.1.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/6HncyfPB/versions/rr511CLW/mesh-lib-fabric-26.1-2.1.0%2Bfabric%2B26.1.jar";
            sha512 = "f361f7ec0bf64168ea80fd5da7e1652583a15939efa3374ba7cd275b5d4329792498ac57aef11d48f71082f57bf2504b2c828a6e8150d3de28f380dffbc2b15d";
          };
          "mods/monkeylib538-fabric-26.2-5.0.0+fabric+26.2.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/gYap5A8T/versions/LDdUWGZa/monkeylib538-fabric-26.2-5.0.0%2Bfabric%2B26.2.jar";
            sha512 = "bb3219ff755c191b85220fd50645d2aa816b140062f7e04a4f7fb8930f20705de523e5dfb4e7e480d1585d3a7ad9613ad02b845c6306eaf8079ba98c2f6f44e1";
          };
          "mods/placeholder-api-3.1.0-beta.1+26.2.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/eXts2L7r/versions/NDqH16LT/placeholder-api-3.1.0-beta.1%2B26.2.jar";
            sha512 = "07b6fc802559d54ec6577f6e2788926ef391d755206c2bfb0528280977885cae4bc0c517d8a53eb6f34092015ebe6c41210627d255aa6504662daefa8fb76397";
          };
          "mods/dcintegration-fabric-MC26.2-3.2.0.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/rbJ7eS5V/versions/ZZwadcBm/dcintegration-fabric-MC26.2-3.2.0.jar";
            sha512 = "88f77aaf200e73dccc06bc94543f8c1a843715bb19d24ff5bc67506392f75d58ebde78e6edf29041f06a10e15cca16a0d125b56943c143bdab31f505f003b8a4";
          };
          "mods/voicechat-discord-fabric-26.1-3.2.0.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/S1jG5YV5/versions/ugN1Nbnv/voicechat-discord-fabric-26.1-3.2.0.jar";
            sha512 = "62bac33228875475841834c9a72178333d3ccb336590436a2e2907eed3d112947e95bad9afff23f3fe9aa2fbb1e065ef7396c364b532c61526b07592aa45eff5";
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
          avatar_url = "https://favelasmp.guz.one/favicon.png";
          attachments = [];
        };
      in
        collectFilesAt modpack "config"
        // {
          "config/bluemap/core.conf" = {
            format = pkgs.formats.keyValue {};
            value = {
              accept-download = true;
              render-thread-count = 1;
              scan-for-mod-resources = false; # We don't have any mod that has assets, so this isn't necessary
              metrics = false;
            };
          };
          "config/bluemap/plugin.conf" = {
            format = pkgs.formats.keyValue {};
            value = {
              live-player-markers = false; # To prevent possible highjacks due to showing members' nickname
              player-render-limit = 3;
            };
          };
          "config/bluemap/webapp.conf" = {
            format = pkgs.formats.keyValue {};
            value = {
              use-cookies = false;
              start-location = ''"world:2213:40:2551:236:0:0:0:0:perspective"'';
            };
          };
          "config/bluemap/webserver.conf" = {
            format = pkgs.formats.keyValue {};
            value = {
              port = serverProperties.server-port + 101;
            };
          };
          "config/FabricProxy-Lite.toml".value = {
            hackOnlineMode = true;
          };
          "config/floodgate/config.yml".value =
            (importYAML (pkgs.fetchurl {
              url = "https://github.com/GeyserMC/Floodgate/raw/refs/heads/master/core/src/main/resources/config.yml";
              hash = "sha256-uHiq3TCdC1Rkw0wzLbm2/g8yq0HU+tNaKhxvJQi9feQ=";
            }))
            // {
              key-file-name = "key.pem";
              username-prefix = ".";
              replace-spaces = true;
              default-locale = "pt_BR";
              player-link = {
                enabled = true;
                require-link = false;
                enable-own-linking = false;
                enable-global-linking = true;
              };
              metrics.enabled = false;
              config-version = 3;
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
          "config/Discord-Integration.toml" =
            config.sops.secrets."services/minecraft/favelasmp-discord".path;
          "config/voicechat/voicechat-server.properties".value = {
            port = 24455;
          };
          "config/voicechat-discord.yml" =
            config.sops.secrets."services/minecraft/favelasmp-voicechat-discord".path;
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
        white-list = true;
      };
    };
  };

  systemd.services = let
    tellraw = msg: ''/tellraw @a ["",{"text":"\n"},{"text":"<FavelaSMP>","bold":true,"color":"gold"},{"text":" ${msg}"},{"text":".\n "}]'';
    tellraw_restart = c: t: ''/tellraw @a ["",{"text":"\n"},{"text":"<FavelaSMP>","bold":true,"color":"gold"},{"text":" O servidor irá reiniciar em "},{"text":"${t}","bold":true,"color":"${c}"},{"text":".\n "}]'';
  in {
    "minecraft-servers-restart-warning-10m" = {
      script = "echo '${tellraw_restart "yellow" "10 minutos"}' > ${cfg.runDir}/favelasmp.stdin";
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
      script = "echo '${tellraw_restart "red" "1 minuto"}' > ${cfg.runDir}/favelasmp.stdin";
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
          "username": "FavelaSMP",
          "avatar_url": "https://favelasmp.guz.one/favicon.png"
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
    "minecraft-server-favelasmp-maintainance" = {
      script =
        pipe [
          "${tellraw "O servidor irá rodar alguns comandos de manutenção em plano de fundo, isso poderá causar um pouco de lag pela próxima hora."}"
        ] [
          (map (v: "echo '${v}' > ${cfg.runDir}/favelasmp.stdin"))
          (join "\n")
        ];
      serviceConfig = {
        Type = "oneshot";
        User = "${cfg.user}";
      };
      startAt = [
        "04:00:00 ${config.time.timeZone}"
      ];
    };
  };

  services.caddy.virtualHosts."favelasmp.guz.one:80" = let
    meshLib = cfg.servers."favelasmp".files."config/mesh-lib/main.json".value;
    bluemapServer = cfg.servers."favelasmp".files."config/bluemap/webserver.conf".value;
  in {
    extraConfig = ''
      root ${inputs.favelasmp.packages.${pkgs.stdenv.hostPlatform.system}.web}
      file_server

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

  networking.firewall.allowedUDPPorts = [24454 24455 19132 30066];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 50000;
      to = 65535;
    }
  ]; # Discord <-> SVC bridge

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
    "services/minecraft/favelasmp-voicechat-discord".owner = config.services.minecraft-servers.user;
    "services/minecraft/favelasmp-whitelist".owner = config.services.minecraft-servers.user;
  };
}
