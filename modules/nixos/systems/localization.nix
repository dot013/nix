{ config, pkgs, inputs, lib, ... }:

let
  cfg = config.localization;
in
{
  options.localization = with lib; with lib.types; {
    locale = mkOption {
      default = "en_US.UTF-8";
      type = str;
      description = "Sets default locale of the host";
    };
    extraLocales = mkOption {
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
    keymap.layout = mkOption {
      default = "br";
      type = str;
    };
    keymap.variant = mkOption {
      default = "";
      type = str;
    };
    keymap.console = mkOption {
      default = "br-abnt2";
      type = str;
    };
    time = {
      zone = mkOption {
        default = "America/Sao_Paulo";
        type = str;
      };
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
      timeZone = cfg.time.zone;
    };
  };
}
