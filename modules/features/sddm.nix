{
  config,
  pkgs,
  ...
}: let
  sddm-astronaut =
    (pkgs.sddm-astronaut.override {
      embeddedTheme = "japanese_aesthetic"; # or any other theme
      # themeConfig = {
      #   # Customize colors and settings
      #   HeaderTextColor = "#d5c4a1";
      #   Background = "Backgrounds/custom.png";
      #   # ... other theme configuration options
      # };
    }).overrideAttrs (oldAttrs: {
      # # Optional: Inject custom background image
      # installPhase =
      #   oldAttrs.installPhase
      #   + ''
      #     chmod u+w $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/
      #     cp ${config.stylix.image} \
      #       $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/custom.png
      #   '';
    });
in {
  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
    extraPackages = with pkgs; [
      kdePackages.qtmultimedia # Required for video backgrounds/audio
    ];
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
  };

  environment.systemPackages = [sddm-astronaut];

  # Disable other display managers
  services.displayManager.gdm.enable = false;
}
