{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.nih.domains.handlers.tailscale;
in {
  imports = [];
  options.nih.domains.handlers.tailscale = with lib;
  with lib.types; {
    enable = mkOption {
      type = bool;
      default = config.nih.domains.enable && config.nih.domains.handler == "tailscale";
    };
  };
  config = with lib;
    mkIf cfg.enable {
      services.tailscale = {
        enable = mkDefault true;
        useRoutingFeatures = mkDefault "server";
      };
    };
}
