{
  config,
  lib,
  ...
}: let
  cfg = config.server.network;
in {
  imports = [];
  options.server.network = with lib;
  with lib.types; {
    enable = mkOption {
      type = bool;
      default = true;
    };
    hostName = mkOption {
      type = str;
      default = config.server.name;
    };
    interface = mkOption {
      type = str;
    };
    localIp = mkOption {
      type = str;
      default = config.server.localIp;
    };
    defaultGateway = mkOption {
      type = str;
      default = "192.168.1.1";
    };
    nameservers = mkOption {
      type = listOf str;
      default = ["1.1.1.1" "8.8.8.8"];
    };
    portForwarding = mkOption {
      type = bool;
      default = false;
    };
    openssh = mkOption {
      type = bool;
      default = true;
    };
    settings = {};
  };
  config = lib.mkIf cfg.enable {
    host.networking.hostName = cfg.hostName;

    networking = {
      dhcpcd.enable = true;
      interfaces."${cfg.interface}".ipv4.addresses = [
        {
          address = cfg.localIp;
          prefixLength = 28;
        }
      ];
      defaultGateway = cfg.defaultGateway;
      nameservers =
        [
          (
            if config.server.tailscale.enable
            then "100.100.100.100"
            else null
          )
        ]
        ++ cfg.nameservers;
    };

    boot.kernel.sysctl."net.ipv4.ip_forward" =
      if cfg.portForwarding
      then 1
      else 0;
    boot.kernel.sysctl."net.ipv6.conf.all.forwarding" =
      if cfg.portForwarding
      then 1
      else 0;

    services.openssh.enable = cfg.openssh;
  };
}
