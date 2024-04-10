{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  lesser-secrets = with builtins;
    fromJSON (readFile ../../secrets/battleship-secrets.lesser.decrypted.json);
  jsonType = pkgs.formats.json {};
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  options.battleship-secrets = with lib;
  with lib.types; {
    lesser = mkOption {
      type = submodule ({...}: {
        freeformType = jsonType.type;
        options = {};
      });
      default = lesser-secrets;
    };
  };
  config = {
    environment.systemPackages = with pkgs; [
      sops
    ];

    sops.defaultSopsFile = ../../secrets/battleship-secrets.yaml;
    sops.defaultSopsFormat = "yaml";

    sops.secrets.lon = {
      owner = config.users.users.guz.name;
    };
    sops.secrets.lat = {
      owner = config.users.users.guz.name;
    };

    sops.age.keyFile = "/home/guz/.config/sops/age/keys.txt";
  };
}
