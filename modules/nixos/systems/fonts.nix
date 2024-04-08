{
  config,
  lib,
  ...
}: let
  cfg = config.my-fonts;
in {
  imports = [];
  options.my-fonts = with lib;
  with lib.types; {
    enable = mkEnableOption "";
    fonts = mkOption {
      type = listOf package;
      default = [];
    };
    user = mkOption {
      type = str;
    };
  };
  config = lib.mkIf cfg.enable {
    fonts = {
      fontconfig.enable = true;
      fontDir.enable = true;
      packages = cfg.fonts;
    };
    systemd.services."my-fonts-setup" = {
      script = ''
        if [ -d "/home/${cfg.user}/.local/share/fonts" ]; then
          echo "";
        else
          ln -sf /run/current-system/sw/share/X11/fonts /home/${cfg.user}/.local/share/fonts;
        fi

        if [ -d "/home/${cfg.user}/.fonts" ]; then
          echo "";
        else
          ln -sf /run/current-system/sw/share/X11/fonts /home/${cfg.user}/.fonts;
        fi
      '';
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
      };
    };
  };
}
