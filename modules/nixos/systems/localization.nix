{ config, pkgs, inputs, lib, ... }:

let
  cfg = config.localization;
in
{
  options.localization = {
    locale = lib.mkOption {
      default = "en_US.UTF-8";
      type = lib.types.str;
      description = "Sets default locale of the host";
    };
    extraLocales = lib.mkOption {
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
      description = "Extra localization settings";
    };

    keymap.layout = lib.mkOption {
      default = "br";
      type = lib.types.str;
    };
    keymap.variant = lib.mkOption {
      default = "";
      type = lib.types.str;
    };
    keymap.console = lib.mkOption {
      default = "br-abnt2";
      type = lib.types.str;
    };

    time = {
      zone = lib.mkOption {
        default = "America/Sao_Paulo";
        type = lib.types.str;
      };
    };
  };
  config = {
    i18n = {
      defaultLocale = cfg.locale;
      extraLocaleSettings = cfg.extraLocales;
    };

    services.xserver = {
      layout = cfg.keymap.layout;
      xkbVariant = cfg.keymap.variant;
    };

    console.keyMap = cfg.keymap.console;

    time = {
      timeZone = cfg.time.zone;
    };
  };
}
