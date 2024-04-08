{
  config,
  lib,
  ...
}: let
  cfg = config.profiles.locale;
in {
  imports = [];
  options.profiles.locale = with lib;
  with lib.types; {
    enable = mkEnableOption "";
    locale = mkOption {
      type = str;
      default = "en_US.UTF-8";
    };
    extraLocales = mkOption {
      type = attrsOf str;
      default = rec {
        LC_ADDRESS = "pt_BR.UTF-8";
        LC_IDENTIFICATION = LC_ADDRESS;
        LC_MEASUREMENT = LC_ADDRESS;
        LC_MONETARY = LC_ADDRESS;
        LC_NAME = LC_ADDRESS;
        LC_NUMERIC = LC_ADDRESS;
        LC_PAPER = LC_ADDRESS;
        LC_TELEPHONE = LC_ADDRESS;
        LC_TIME = LC_ADDRESS;
      };
    };
    keymap.layout = mkOption {
      type = str;
      default = "br";
    };
    keymap.variant = mkOption {
      type = str;
      default = "";
    };
    keymap.console = mkOption {
      type = str;
      default = "br-abnt2";
    };
    timeZone = mkOption {
      type = str;
      default = "America/Sao_Paulo";
    };
  };
  config = {
    i18n = {
      defaultLocale = cfg.locale;
      extraLocaleSettings = cfg.extraLocales;
    };

    services.xserver = {
      xkb.layout = cfg.keymap.layout;
      xkb.variant = cfg.keymap.variant;
    };

    console.keyMap = cfg.keymap.console;

    time = {
      timeZone = cfg.timeZone;
    };
  };
}
