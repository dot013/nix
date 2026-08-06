{pkgs, ...}: {
  # Plymouth
  boot.plymouth = {
    enable = true;

    theme = "dark_planet";
    themePackages = with pkgs; [
      (adi1090x-plymouth-themes.override {selected_themes = ["dark_planet"];})
    ];

    font = "${pkgs.redhat-official-fonts}/share/fonts/truetype/RedHatDisplay-Regular.ttf";
    logo = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake.png";
  };

  # Silent Boot
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "splash"
    "intremap=on"
    "boot.shell_on_fail"
    "udev.log_priority=3"
    "rd.systemd.show_status=auto"
  ];

  # Hide the OS choice for bootloaders.
  # It's still possible to open the bootloader list by pressing any key
  # It will just not appear on screen unless a key is pressed
  boot.loader.timeout = 0;

  stylix.targets.plymouth.enable = false;
}
