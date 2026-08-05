{
  pkgs,
  self,
  ...
}: {
  fonts.packages = with pkgs; [
    google-fonts
    nerd-fonts.fira-code
    self.packages.${pkgs.stdenv.hostPlatform.system}.cal-sans
  ];
  fonts.fontDir.enable = true;
  fonts.fontconfig.enable = true;
}
