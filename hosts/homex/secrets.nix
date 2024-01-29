{ config, ... }:
{
  imports = [ ];
  options = { };
  config = {
    sops.defaultSopsFile = ../../secrets/homex-secrets.yaml;
    sops.defaultSopsFormat = "yaml";

    sops.secrets."forgejo/user1/name" = {
      owner = config.homelab.forgejo.user;
    };
    sops.secrets."forgejo/user1/password" = {
      owner = config.homelab.forgejo.user;
    };
    sops.secrets."forgejo/user1/email" = {
      owner = config.homelab.forgejo.user;
    };

    sops.age.keyFile = "/home/guz/.config/sops/age/keys.txt";
  };
}