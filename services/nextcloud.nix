{
  config,
  pkgs,
  ...
}: let
  cfg = config.services.nextcloud;
in {
  imports = [
    "${fetchTarball {
      url = "https://github.com/onny/nixos-nextcloud-testumgebung/archive/fa6f062830b4bc3cedb9694c1dbf01d5fdf775ac.tar.gz";
      sha256 = "0gzd0276b8da3ykapgqks2zhsqdv4jjvbv97dsxg0hgrhb74z0fs";
    }}/nextcloud-extras.nix"
  ];

  services.nextcloud = let
    version = "33";
  in {
    enable = false;
    package = pkgs."nextcloud${version}";
    webserver = "caddy";
    hostName = "nextcloud.local";
    appstoreEnable = false;
    configureRedis = true;
    database.createLocally = true;
    extraApps = {
      inherit
        (pkgs."nextcloud${version}Packages".apps)
        # mail
        calendar
        contacts
        memories
        news
        notes
        # recognize
        ;
    };
    config = {
      adminuser = "admin";
      adminpassFile = config.sops.secrets."services/nextcloud/adminpass".path;

      dbtype = "pgsql";

      # objectstore.s3 = {
      #   enable = true;
      #   verify_bucket_exists = false;
      #   bucket = "nextcloud";
      #   hostname = "localhost";
      #   port = 3461;
      #   usePathStyle = true;
      #   useSsl = false;
      #   region = config.services.garage.settings.s3_api.s3_region;
      #   key = "GK7b6d9214adf40850e5f39d66";
      #   secretFile = config.sops.secrets."nextcloud/s3/secret".path;
      #   # sseCKeyFile = config.sops.secrets."nextcloud/s3/sseC".path; # Needs SSL
      # };
    };
    settings = {
      "auth.authtoken.v1.disabled" = true;
      debug = false;
      default_language = "pt_BR";
      default_locale = "pt_BR";
      default_phone_region = "BR";
      default_timezone = config.time.timeZone;
      loglevel = 2;
      maintenance_window_start = 4; # 1:00 AM at UTC-3
      trusted_proxies = ["127.0.0.1"];
    };
    phpExtraExtensions = all:
      with all; [
        opcache
      ];
    phpOptions = {
      "opcache.interned_strings_buffer" = 10;
      "opcache.jit" = 1255;
      "opcache.jit_buffer_size" = "8M";
      "opcache.revalidate_freq" = 60;
      "opcache.save_comments" = 1;
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = cfg.datadir;
      user = "nextcloud";
      group = "nextcloud";
    }
  ];

  # sops.secrets = {
  #   "services/nextcloud/adminpass" = {owner = "nextcloud";};
  # };
}
