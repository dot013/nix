{
  inputs,
  lib,
  modulesPath,
  pkgs,
  self,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  networking.hostName = "infiltrator";

  environment.systemPackages =
    [
      inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko
      inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko-install

      (pkgs.callPackage (
        {
          symlinkJoin,
          fastfetchMinimal,
          makeWrapper,
          ...
        }:
          symlinkJoin ({
              paths = [fastfetchMinimal];
              nativeBuildInputs = [makeWrapper];
              postBuild = "wrapProgram $out/bin/fastfetch --add-flags '-l ${../../static/infiltrator.txt} --color red'";
            }
            // {inherit (fastfetchMinimal) name passthru pname version;})
      ) {})
    ]
    ++ (with self.packages.${pkgs.stdenv.hostPlatform.system}.devkit; [
      git
      lazygit
      neovim
      starship
      yazi
      zellij
      zsh
    ]);

  programs.zsh.enable = true;
  users.users.root.shell = self.packages.${pkgs.stdenv.hostPlatform.system}.devkit.zsh;

  environment.etc = with lib; let
    joinPath = p: strings.normalizePath (join "/" (map (v: toString v) p));
    readRecur = p:
      pipe p [
        readDir
        (mapAttrs (n: v:
          if v != "regular"
          then readRecur (joinPath [p n])
          else v))
        (mapAttrsToList (n: v:
          if isList v
          then v
          else (joinPath [p n])))
        flatten
      ];
    listFiles = dir:
      map (p:
        pipe p [
          (splitString "/")
          (l: sublist 4 (length l) l)
          joinPath
          toString
        ]) (readRecur dir);
  in
    pipe (listFiles ../..) [
      (map (p: {
        name = "nixos/${p}";
        value = {
          mode = "0755";
          user = "root";
          group = "root";
          text = joinPath [../.. p];
        };
      }))
      listToAttrs
    ];

  # Locale
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = rec {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = LC_ADDRESS;
    LC_MEASUREMENT = LC_ADDRESS;
    LC_MONETARY = LC_ADDRESS;
    LC_NAME = LC_ADDRESS;
    LC_NUMERIC = LC_ADDRESS;
    LC_PAPER = LC_ADDRESS;
    LC_TELEPHONE = LC_ADDRESS;
    LC_TIME = LC_ADDRESS;
  };

  # Keyboard
  services.xserver.xkb.layout = "br";
  console.keyMap = "br-abnt2";

  # QMK keyboard
  hardware.keyboard.qmk.enable = true;
  services.udev.packages = with pkgs; [via vial];

  # Nix
  nix.settings.experimental-features = ["nix-command" "flakes"];

  nix.allowUnfreeList = ["via"];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
