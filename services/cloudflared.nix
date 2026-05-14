{config, ...}: {
  services.cloudflared.enable = true;
  services.cloudflared.tunnels = {
    "9ed8b48f-9585-4a67-9895-114b162172fb" = {
      certificateFile = config.sops.secrets."services/cloudflared/guzone-cert".path;
      credentialsFile = config.sops.secrets."services/cloudflared/guzone-cred".path;
      default = "http_status:404";
    };
  };

  sops.secrets = {
    "services/cloudflared/guzone-cert" = {};
    "services/cloudflared/guzone-cred" = {};
  };
}
