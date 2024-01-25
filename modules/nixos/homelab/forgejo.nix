{ config, lib, pkgs, ... }:

let
  cfg = config.homelab.forgejo;
in
{
  imports = [ ];
  options.homelab.forgejo = with lib; with lib.types; {
    enable = mkEnableOption "";
    user = mkOption {
      type = str;
      default = "forgejo";
    };
    data = {
      root = mkOption {
        type = path;
        default = config.homelab.storage + /forgejo;
      };
    };
    settings = {
      name = mkOption {
        type = str;
        default = "Forgejo: Beyond coding. We forge";
      };
      prod = mkOption {
        type = bool;
        default = true;
      };
      repo.defaultUnits = mkOption {
        type = listOf (enum [
          "repo.code"
          "repo.releases"
          "repo.issues"
          "repo.pulls"
          "repo.wiki"
          "repo.projects"
          "repo.packages"
          "repo.actions"
        ]);
        default = [
          "repo.code"
          "repo.issues"
          "repo.pulls"
        ];
      };
      repo.disabledUnits = mkOption {
        type = listOf (enum [
          "repo.issues"
          "repo.ext_issues"
          "repo.pulls"
          "repo.wiki"
          "repo.ext_wiki"
          "repo.projects"
          "repo.packages"
          "repo.actions"
        ]);
        default = [ ];
      };
      cors.enable = mkOption {
        type = bool;
        default = false;
      };
      cors.domains = mkOption {
        type = listOf str;
        default = [ ];
      };
      cors.methods = mkOption {
        type = listOf str;
        default = [ ];
      };
      ui.defaultTheme = mkOption {
        type = str;
        default = "forgejo-auto";
      };
      ui.themes = mkOption {
        type = listOf str;
        default = [
          "forgejo-auto"
          "forgejo-light"
          "forgejo-dark"
          "auto"
          "gitea"
          "arc-green"
        ];
      };
      server.protocol = mkOption {
        type = enum [ "http" "https" "fcgi" "http+unix" "fcgi+unix" ];
        default = "http";
      };
      server.domain = mkOption {
        type = str;
        default = "localhost";
      };
      server.port = mkOption {
        type = port;
        default = 3000;
      };
      server.address = mkOption {
        type = either str path;
        default = if hasSuffix "+unix" cfg.settings.server.protocol then "/run/forgejo/forgejo.sock" else "0.0.0.0";
      };
      server.url = mkOption {
        type = str;
        default = "http://${cfg.settings.server.domain}:${toString cfg.settings.server.port}";
      };
      server.offline = mkOption {
        type = bool;
        default = false;
      };
      server.compression = mkOption {
        type = bool;
        default = false;
      };
      server.landingPage = mkOption {
        type = enum [ "home" "explore" "organizations" "login" str ];
        default = "home";
      };
      service.registration = mkOption {
        type = bool;
        default = false;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      user = cfg.user;
      group = cfg.user;
      stateDir = toString cfg.data.root;
      useWizard = false;
      database = {
        user = cfg.user;
        type = "sqlite3";
      };
      settings = with builtins; {
        DEFAULT = {
          APP_NAME = cfg.settings.name;
          RUN_MODE = if cfg.settings.prod then "prod" else "dev";
        };
        repository = {
          DISABLED_REPO_UNITS = concatStringsSep "," cfg.settings.repo.disabledUnits;
          DEFAULT_REPO_UNITS = concatStringsSep "," cfg.settings.repo.defaultUnits;
        };
        cors = {
          ENABLED = cfg.settings.cors.enable;
          ALLOW_DOMAIN = concatStringsSep "," cfg.settings.cors.domains;
          METHODS = concatStringsSep "," cfg.settings.cors.methods;
        };
        ui = {
          DEFAULT_THEME = cfg.settings.ui.defaultTheme;
          THEMES = concatStringsSep "," cfg.settings.ui.themes;
        };
        server = {
          PROTOCOL = cfg.settings.server.protocol;
          DOMAIN = cfg.settings.server.domain;
          ROOT_URL = cfg.settings.server.url;
          HTTP_ADDR = cfg.settings.server.address;
          HTTP_PORT = cfg.settings.server.port;
          OFFLINE_MODE = cfg.settings.server.offline;
          ENABLE_GZIP = cfg.settings.server.compression;
          LANDING_PAGE = cfg.settings.server.landingPage;
        };
        service = {
          DISABLE_REGISTRATION = if cfg.settings.service.registration then false else true;
        };
      };
    };
  };
}



