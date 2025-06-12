{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  environment.systemPackages = with pkgs; [
    sops
  ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/sops/keys.txt";

  sops.secrets."guz/password" = {
    owner = config.users.users.guz.name;
  };
  sops.secrets."guz/git-script" = {
    owner = config.users.users.guz.name;
  };
}
