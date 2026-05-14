{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib; {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  environment.systemPackages = with pkgs; [
    sops
  ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "${config.users.users."guz".home}/.config/age/keys.txt";

  sops.secrets."guz/password" = {
    owner = config.users.users.guz.name;
  };
  sops.secrets."guz/git-envs" = {
    owner = config.users.users.guz.name;
  };
}
