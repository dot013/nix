{
  inputs,
  self,
  config,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # Users
  users.users."guz" = {
    useDefaultShell = true;
    isNormalUser = true;

    password = null;
    extraGroups = ["wheel" "guz"];
  };
  users.groups."guz" = {};

  environment.systemPackages =
    [
      inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.default
    ]
    ++ (with self.packages.${pkgs.stdenv.hostPlatform.system}.devkit; [
      git
      lazygit
      neovim
      starship
      tmux
      yazi
      zellij
      zsh
    ]);

  # Locale
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = let
    locale = "pt_BR.UTF-8";
  in {
    LC_ADDRESS = locale;
    LC_IDENTIFICATION = locale;
    LC_MEASUREMENT = locale;
    LC_MONETARY = locale;
    LC_NAME = locale;
    LC_NUMERIC = locale;
    LC_PAPER = locale;
    LC_TELEPHONE = locale;
    LC_TIME = locale;
  };

  # Keyboard
  services.xserver.xkb = {
    layout = "br";
  };
  console.keyMap = "br-abnt2";

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  # Nix
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };

  nixpkgs.config.allowBroken = true;

  # boot.kernelPackages = pkgs.linuxPackages_latest;
}
