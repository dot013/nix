{
  config,
  self,
  ...
}: {
  imports = [
    self.nixosModules.cloudflared-caddy
  ];

  services.cloudflared.enable = true;
  services.cloudflared.tunnels = {
    "a17157ee-5c16-4522-9d86-15b8f1830aa2" = {
      certificateFile = config.sops.secrets."services/cloudflared/capytalcc-cert".path;
      credentialsFile = config.sops.secrets."services/cloudflared/capytalcc-cred".path;
      caddy-domain = "capytal.cc";
      default = "http_status:404";
    };
    "9d90c3d6-a3a7-4265-9576-13d08415701b" = {
      certificateFile = config.sops.secrets."services/cloudflared/capytalcompany-cert".path;
      credentialsFile = config.sops.secrets."services/cloudflared/capytalcompany-cred".path;
      caddy-domain = "capytal.company";
      default = "http_status:404";
    };
    "9ed8b48f-9585-4a67-9895-114b162172fb" = {
      certificateFile = config.sops.secrets."services/cloudflared/guzone-cert".path;
      credentialsFile = config.sops.secrets."services/cloudflared/guzone-cred".path;
      caddy-domain = "guz.one";
      default = "http_status:404";
    };
    "7de4a448-cf2e-4fc1-b37c-85845e14af75" = {
      certificateFile = config.sops.secrets."services/cloudflared/keikoswork-cert".path;
      credentialsFile = config.sops.secrets."services/cloudflared/keikoswork-cred".path;
      caddy-domain = "keikos.work";
      default = "http_status:404";
    };
    "50cd6a81-1198-4b42-b26b-9b1a5ed2ebf8" = {
      certificateFile = config.sops.secrets."services/cloudflared/koiswork-cert".path;
      credentialsFile = config.sops.secrets."services/cloudflared/koiswork-cred".path;
      caddy-domain = "kois.work";
      default = "http_status:404";
    };
  };

  services.caddy.enable = true;

  sops.secrets = {
    "services/cloudflared/capytalcc-cert" = {};
    "services/cloudflared/capytalcc-cred" = {};
    "services/cloudflared/capytalcompany-cert" = {};
    "services/cloudflared/capytalcompany-cred" = {};
    "services/cloudflared/guzone-cert" = {};
    "services/cloudflared/guzone-cred" = {};
    "services/cloudflared/keikoswork-cert" = {};
    "services/cloudflared/keikoswork-cred" = {};
    "services/cloudflared/koiswork-cert" = {};
    "services/cloudflared/koiswork-cred" = {};
  };
}
