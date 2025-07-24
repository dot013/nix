{pkgs, ...}: {
  imports = [
    ../worm/configuration.nix
  ];

  home-manager.users.guz = import ./default.nix;

  services.flatpak.enable = true;

  fonts.fontDir.enable = true;
  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    google-fonts
    nerd-fonts.fira-code
    (stdenv.mkDerivation rec {
      name = "Cal Sans";
      pname = "calsans";
      version = "1.0.0";
      src = pkgs.fetchzip {
        url = "https://github.com/calcom/font/releases/download/v${version}/CalSans_Semibold_v${version}.zip";
        stripRoot = false;
        hash = "sha256-JqU64JUgWimJgrKX3XYcml8xsvy//K7O5clNKJRGaTM=";
      };
      installPhase = ''
        runHook preInstall
        install -m444 -Dt $out/share/fonts/truetype fonts/webfonts/*.ttf
        runHook postInstall
      '';
      meta = with lib; {
        homepage = "https://github.com/calcom/font";
        license = licenses.ofl;
        platforms = platforms.all;
      };
    })
  ];

  # Xremap run-as-user
  hardware.uinput.enable = true;
  users.groups.uinput.members = ["guz"];
  users.groups.input.members = ["guz"];

  # TODO: Activity watch server
  networking.firewall.allowedTCPPorts = [5600];
}
