{...}: {
  services.anubis.defaultOptions = {
    policy = {
      useDefaultBotRules = true;
    };
    settings = {
      OG_PASSTHROUGH = true;
      SERVE_ROBOTS_TXT = true;
      WEBMASTER_EMAIL = "contact@guz.one";
    };
  };
}
