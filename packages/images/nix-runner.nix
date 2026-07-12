{
  buildEnv,
  dockerTools,
  nixSrc,
  pkgs,
}:
dockerTools.buildImage {
  name = "nix-runner";
  tag = "latest";

  fromImage = import (nixSrc + "/docker.nix") {
    inherit pkgs;
    name = "nix-runner-base";
    maxLayers = 10;
    extraPkgs = with pkgs; [
      nodejs
    ];
    channelURL = "https://nixos.org/channels/nixpkgs-unstable";
    nixConf = {
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      experimental-features = ["nix-command" "flakes"];
    };
  };
  fromImageName = null;
  fromImageTag = "latest";

  copyToRoot = buildEnv {
    name = "nix-runner-root";
    paths = [pkgs.coreutils-full];
    pathsToLink = ["/bin"];
  };
}
