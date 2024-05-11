{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  lesser-secrets = with builtins;
    fromJSON (readFile ../../secrets/spacestation-secrets.lesser.decrypted.json);
  jsonType = pkgs.formats.json {};
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  options.homelab-secrets = with lib;
  with lib.types; {
    lesser = mkOption {
      type = submodule ({...}: {
        freeformType = jsonType.type;
        options = {};
      });
      default = lesser-secrets;
    };
  };
  config = with lib; {
    environment.systemPackages = with pkgs; [
      sops
    ];

    sops.defaultSopsFile = ../../secrets/spacestation-secrets.yaml;
    sops.defaultSopsFormat = "yaml";

    sops.secrets."guz/password" = {
      owner = config.users.users."guz".name;
    };

    sops.secrets."muse/secrets" = {};

    sops.secrets."forgejo/user1/name" = mkIf config.services.forgejo.enable {
      owner = config.services.forgejo.user;
    };
    sops.secrets."forgejo/user1/password" = mkIf config.services.forgejo.enable {
      owner = config.services.forgejo.user;
    };
    sops.secrets."forgejo/user1/email" = mkIf config.services.forgejo.enable {
      owner = config.services.forgejo.user;
    };
    sops.secrets."forgejo/git-password" = mkIf config.services.forgejo.enable {
      owner = config.services.forgejo.user;
    };

    sops.age.keyFile = "/home/guz/.config/sops/age/keys.txt";
  };
}
