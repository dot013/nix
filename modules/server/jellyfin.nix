{ config, lib, pkgs, ... }:

let
  cfg = config.server.jellyfin;
  networkConfig = pkgs.writeTextFile {
    name = "network.json";
    text = builtins.toJSON cfg.settings.network;
  };
  encodingConfig = pkgs.writeTextFile {
    name = "encoding.json";
    text = builtins.toJSON cfg.settings.encoding;
  };
  systemConfig = pkgs.writeTextFile {
    name = "encoding.json";
    text = builtins.toJSON cfg.settings.system;
  };
in
{
  imports = [
    ./jellyseerr.nix
  ];
  options.server.jellyfin = with lib; with lib.types; {
    enable = mkEnableOption "";
    user = mkOption {
      type = str;
      default = "jellyfin";
    };
    package = mkOption {
      type = package;
      default = pkgs.jellyfin;
    };
    domain = mkOption {
      type = str;
      default = "jellyfin." + config.server.domain;
    };
    port = mkOption {
      type = port;
      default = 8096;
    };
    data = {
      root = mkOption {
        type = path;
        default = config.server.storage + /jellyfin;
      };
    };
    jellyseerr = mkOption {
      type = bool;
      default = true;
    };
    settings = {
      network = mkOption {
        type = (submodule {
          freeformType = (pkgs.formats.json { }).type;
          options = {
            AutoDiscovery = mkOption {
              type = bool;
              default = true;
            };
            AutoDiscoveryTracing = mkOption {
              type = bool;
              default = false;
            };
            BaseUrl = mkOption {
              type = str;
              default = "https://${cfg.domain}";
            };
            CertificatePassword = mkOption {
              type = str;
              default = "";
            };
            CertificatePath = mkOption {
              type = str;
              default = "";
            };
            EnableHttps = mkOption {
              type = bool;
              default = false;
            };
            EnableIPV4 = mkOption {
              type = bool;
              default = true;
            };
            EnableIPV6 = mkOption {
              type = bool;
              default = false;
            };
            EnablePublishedServerUriByRequest = mkOption {
              type = bool;
              default = false;
            };
            EnableSSDPTracing = mkOption {
              type = bool;
              default = false;
            };
            EnableRemoteAccess = mkOption {
              type = bool;
              default = true;
            };
            EnableUPnP = mkOption {
              type = bool;
              default = false;
            };
            GatewayMonitorPeriod = mkOption {
              type = int;
              default = 60;
            };
            HDHomerunPortRange = mkOption {
              type = str;
              default = "";
            };
            HttpServerPortNumber = mkOption {
              type = port;
              default = cfg.port;
            };
            HttpsPortNumber = mkOption {
              type = port;
              default = cfg.settings.network.PublicHttpsPort;
            };
            IgnoreVirtualInterfaces = mkOption {
              type = bool;
              default = true;
            };
            IsRemoteIPFilterBlacklist = mkOption {
              type = bool;
              default = false;
            };
            KnownProxies = mkOption {
              type = str;
              default = "";
            };
            LocalNetworkAddresses = mkOption {
              type = str;
              default = "";
            };
            LocalNetworkSubnets = mkOption {
              type = str;
              default = "";
            };
            PublicHttpsPort = mkOption {
              type = port;
              default = 8920;
            };
            PublicPort = mkOption {
              type = port;
              default = cfg.settings.network.HttpServerPortNumber;
            };
            PublishedServerUriBySubnet = mkOption {
              type = str;
              default = "";
            };
            RequireHttps = mkOption {
              type = bool;
              default = false;
            };
            RemoteIPFilter = mkOption {
              type = str;
              default = "";
            };
            SSDPTracingFilter = mkOption {
              type = str;
              default = "";
            };
            TrustAllIP6Interfaces = mkOption {
              type = bool;
              default = false;
            };
            UDPPortRange = mkOption {
              type = str;
              default = "";
            };
            UDPSendCount = mkOption {
              type = int;
              default = 2;
            };
            UDPSendDelay = mkOption {
              type = int;
              default = 100;
            };
            UPnPCreateHttpPortMap = mkOption {
              type = bool;
              default = false;
            };
            VirtualInterfacenNames = mkOption {
              type = str;
              default = "vEthernet*";
            };
          };
        });
        default = { };
      };
      encoding = mkOption {
        type =
          (submodule {
            freeformType = (pkgs.formats.json { }).type;
            options = {
              AllowOnDemandMetadataBasedKeyframeExtractionForExtensions.string = mkOption {
                type = listOf str;
                default = [ "mkv" ];
              };
              DeinterlaceDoubleRate = mkOption {
                type = bool;
                default = false;
              };
              DeinterlaceMethod = mkOption {
                type = str;
                default = "yadif";
              };
              DownMixAudioBoost = mkOption {
                type = int;
                default = 2;
              };
              EnableDecodingColorDepth10Hevc = mkOption {
                type = bool;
                default = true;
              };
              EnableDecodingColorDepth10Vp9 = mkOption {
                type = bool;
                default = true;
              };
              EnableEnhancedNvdecDecoder = mkOption {
                type = bool;
                default = true;
              };
              EnableFallbackFont = mkOption {
                type = bool;
                default = false;
              };
              EnableHardwareEncoding = mkOption {
                type = bool;
                default = true;
              };
              EnableIntelLowPowerH264HwEncoder = mkOption {
                type = bool;
                default = false;
              };
              EnableIntelLowPowerHevcHwEncoder = mkOption {
                type = bool;
                default = false;
              };
              EnableSubtitleExtraction = mkOption {
                type = bool;
                default = true;
              };
              EnableThrottling = mkOption {
                type = bool;
                default = false;
              };
              EnableTonemapping = mkOption {
                type = bool;
                default = false;
              };
              EnableVppTonemapping = mkOption {
                type = bool;
                default = false;
              };
              EncoderAppPathDisplay = mkOption {
                type = either path str;
                default = "${pkgs.jellyfin-ffmpeg}/bin/ffmpeg";
              };
              EncodingThreadCount = mkOption {
                type = int;
                default = -1;
              };
              H264Crf = mkOption {
                type = int;
                default = 23;
              };
              H265Crf = mkOption {
                type = int;
                default = 28;
              };
              HardwareDecodingCodecs.string = mkOption {
                type = listOf str;
                default = [ "h254" "vc1" ];
              };
              MaxMuxingQueueSize = mkOption {
                type = int;
                default = 2048;
              };
              PreferSystemNativeHwDecoder = mkOption {
                type = bool;
                default = true;
              };
              ThrottleDelaySeconds = mkOption {
                type = int;
                default = 180;
              };
              TonemappingAlgorithm = mkOption {
                type = str;
                default = "bt2390";
              };
              TonemappingDesat = mkOption {
                type = int;
                default = 0;
              };
              TonemappingMode = mkOption {
                type = str;
                default = "auto";
              };
              TonemappingParam = mkOption {
                type = int;
                default = 0;
              };
              TonemappingPeak = mkOption {
                type = int;
                default = 100;
              };
              TonemappingRange = mkOption {
                type = str;
                default = "auto";
              };
              VaapiDevice = mkOption {
                type = either path str;
                default = "/dev/dri/renderD128";
              };
              VppTonemappingBrightness = mkOption {
                type = int;
                default = 16;
              };
              VppTonemappingContrast = mkOption {
                type = int;
                default = 1;
              };
            };
          });
        default = { };
      };
      system = mkOption {
        type = (submodule {
          freeformType = (pkgs.formats.json { }).type;
          options = {
            ActivityLogRetentionDays = mkOption {
              type = int;
              default = 30;
            };
            AllowClientLogUpload = mkOption {
              type = bool;
              default = true;
            };
            CodecsUsed = mkOption {
              type = str;
              default = "";
            };
            ContentTypes = mkOption {
              type = str;
              default = "";
            };
            CorsHost.string = mkOption {
              type = listOf str;
              default = [ "*" ];
            };
            DisableLiveTvChannelUserDataName = mkOption {
              type = bool;
              default = true;
            };
            DisplaySpecialsWithinSeasons = mkOption {
              type = bool;
              default = true;
            };
            EnableCaseSensitiveItemIds = mkOption {
              type = bool;
              default = true;
            };
            EnableExternalContentInSuggestions = mkOption {
              type = bool;
              default = true;
            };
            EnableFolderView = mkOption {
              type = bool;
              default = false;
            };
            EnableGroupingIntoCollections = mkOption {
              type = bool;
              default = false;
            };
            EnableMetrics = mkOption {
              type = bool;
              default = false;
            };
            EnableNormalizedItemByNameIds = mkOption {
              type = bool;
              default = true;
            };
            EnableSlowResponseWarning = mkOption {
              type = bool;
              default = true;
            };
            ImageExtractionTimeoutMs = mkOption {
              type = int;
              default = 0;
            };
            ImageSavingConvention = mkOption {
              type = str;
              default = "Legacy";
            };
            IsPortAuthorized = mkOption {
              type = bool;
              default = true;
            };
            IsStartupWizardCompleted = mkOption {
              type = bool;
              default = true;
            };
            LibraryMetadataRefreshConcurrency = mkOption {
              type = int;
              default = 0;
            };
            LibraryMonitorDelay = mkOption {
              type = int;
              default = 60;
            };
            LogFileRetentionDays = mkOption {
              type = int;
              default = 3;
            };
            MaxAudiobookResume = mkOption {
              type = int;
              default = 5;
            };
            MaxResumePct = mkOption {
              type = int;
              default = 90;
            };
            MetadataCountryCode = mkOption {
              type = str;
              default = "US";
            };
            MetadataNetworkPath = mkOption {
              type = str;
              default = "";
            };
            MetadataOptions.MetadataOptions = mkOption {
              default = [
                {
                  ItemType = "Book";
                }
                {
                  ItemType = "Movie";
                }
                {
                  ItemType = "MusicVideo";
                  DisabledMetadataFetchers.string = [ "The Open Movie Database" ];
                  DisabledImageFetchers.string = [ "The Open Movie Database" ];
                }
                {
                  ItemType = "Series";
                }
                {
                  ItemType = "MusicAlbum";
                  DisabledMetadataFetchers.string = [ "TheAudioDB" ];
                }
                {
                  ItemType = "MusicArtist";
                  DisabledMetadataFetchers.string = [ "TheAudioDB" ];
                }
                {
                  ItemType = "BoxSet";
                }
                {
                  ItemType = "Season";
                }
                {
                  ItemType = "Episode";
                }
              ];
              type = listOf (submodule {
                options = {
                  ItemType = mkOption {
                    default = "Movie";
                    type = str;
                  };
                  DisabledMetadataSavers.string = mkOption {
                    default = [ ];
                    type = listOf str;
                  };
                  LocalMetadataReaderOrder.string = mkOption {
                    default = [ ];
                    type = listOf str;
                  };
                  DisabledMetadataFetchers.string = mkOption {
                    default = [ ];
                    type = listOf str;
                  };
                  MetadataFetcherOrder.string = mkOption {
                    default = [ ];
                    type = listOf str;
                  };
                  DisabledImageFetchers.string = mkOption {
                    default = [ ];
                    type = listOf str;
                  };
                  ImageFetcherOrder.string = mkOption {
                    default = [ ];
                    type = listOf str;
                  };
                };
              });
            };
            MetadataPath = mkOption {
              type = str;
              default = "";
            };
            MinAudiobookResume = mkOption {
              type = int;
              default = 5;
            };
            MinResumeDurationSeconds = mkOption {
              type = int;
              default = 300;
            };
            MinResumePct = mkOption {
              type = int;
              default = 5;
            };
            PathSubstitutions = mkOption {
              type = str;
              default = "";
            };
            PluginRepositories.RepositoryInfo = mkOption {
              default = [{
                Name = "Jellyfin Stable";
                Url = "https://repo.jellyfin.org/releases/plugin/manifest-stable.json";
                Enabled = true;
              }];
              type = listOf (submodule {
                options = {
                  Name = mkOption {
                    type = str;
                  };
                  Url = mkOption {
                    type = str;
                  };
                  Enabled = mkOption {
                    default = true;
                    type = bool;
                  };
                };
              });
            };
            PreferredMetadataLanguage = mkOption {
              type = str;
              default = "en";
            };
            QuickConnectAvailable = mkOption {
              type = bool;
              default = true;
            };
            RemoteClientBitrateLimit = mkOption {
              type = int;
              default = 0;
            };
            RemoveOldPlugins = mkOption {
              type = bool;
              default = false;
            };
            SaveMetadataHidden = mkOption {
              type = bool;
              default = false;
            };
            ServerName = mkOption {
              type = str;
              default = "";
            };
            SkipDeserializationForBasicTypes = mkOption {
              type = bool;
              default = true;
            };
            SlowResponseThreshold = mkOption {
              type = int;
              default = 500;
            };
            SortRemoveCharacters.string = mkOption {
              type = listOf str;
              default = [ "," "&" "-" "{" "}" "'" ];
            };
            SortRemoveWords.string = mkOption {
              type = listOf str;
              default = [ "the" "a" "an" ];
            };
            SortReplaceCharacters.string = mkOption {
              type = listOf str;
              default = [ "." "+" "%" ];
            };
            UICulture = mkOption {
              type = str;
              default = "en-US";
            };
          };
        });
        default = { };
      };
    };
  };
  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      package = cfg.package;
      user = cfg.user;
      group = cfg.user;
      openFirewall = true;
    };

    server.jellyseerr.enable = cfg.jellyseerr;

    systemd.services."homelab-jellyfin-config" = {
      script = ''
        jellyfin_dir="/var/lib/jellyfin";

        function network_file() {
          echo '<?xml version="1.0" enconding="utf-8"?>';
          echo '<NetworkConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
          cat ${networkConfig} | ${pkgs.yq-go}/bin/yq --input-format json --output-format xml;
          echo '</NetworkConfiguration>';
        }
        function encoding_file() {
          echo '<?xml version="1.0" enconding="utf-8"?>';
          echo '<EncodingOptions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
          cat ${encodingConfig} | ${pkgs.yq-go}/bin/yq --input-format json --output-format xml;
          echo '</EncodingOptions>';
        }
        function system_file() {
          echo '<?xml version="1.0" enconding="utf-8"?>';
          echo '<ServerConfiguraion xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
          cat ${systemConfig} | ${pkgs.yq-go}/bin/yq --input-format json --output-format xml;
          echo '</ServerConfiguraion>';
        }

        mkdir -p $jellyfin_dir/config;

        touch "$jellyfin_dir/config/network.xml";
        echo "$(network_file)" > "$jellyfin_dir/config/network.xml";

        touch "$jellyfin_dir/config/encoding.xml";
        echo "$(encoding_file)" > "$jellyfin_dir/config/encoding.xml";

        touch "$jellyfin_dir/config/system.xml";
        echo "$(system_file)" > "$jellyfin_dir/config/system.xml";
      '';
      wantedBy = [ "multi-user.target" ];
      after = [ "jellyfin.service" ];
      serviceConfig = {
        Type = "oneshot";
      };
    };
  };
}

