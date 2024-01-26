{ config, ... }:
{
  imports = [ ];
  options = { };
  config = {
    sops.defaultSopsFile = ../../secrets/homex-secrets.yaml;
    sops.defaultSopsFormat = "yaml";

    sops.age.keyFile = "/home/guz/.config/sops/age/keys.txt";
  };
}
