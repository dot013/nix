{ config, lib, pkgs, ... }:

let
  cfg = config.my-fonts;
in
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
    fonts-presets = {
      libreoffice = mkOption {
        type = bool;
        default = true;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    fonts = {
      fontconfig.enable = true;
      fontDir.enable = true;
      packages = with pkgs;
        (if cfg.fonts-presets.libreoffice then [
          dejavu_fonts
          gentium
          gentium-book-basic
          liberation_ttf
          liberation-sans-narrow
          libertinus
          (google-fonts.override {
            fonts = [
              "Alef"
              "Amiri"
              "Amiri Quran"
              "Caladea"
              "Carlito"
              "Frank Ruhl Libre"
              "Gentium Plus"
              "Mirian Libre"
              "Noto Kufi Arabic"
              "Noto Naskh Arabic"
              "Noto Sans"
              "Noto Sans Arabic"
              "Noto Sans Armenian"
              "Noto Sans Georgian"
              "Noto Sans Hebrew"
              "Noto Sans Lao"
              "Noto Sans Lisu"
              "Noto Serif"
              "Noto Serif Armenian"
              "Noto Serif Georgian"
              "Noto Serif Hebrew"
              "Noto Serif Lao"
              "Reem Kufi"
              "Rubik"
              "Scheherazade New"
            ];
          })
          (stdenv.mkDerivation rec {
            pname = "david-libre";
            version = "1.001";
            src = pkgs.fetchzip {
              url = "https://github.com/meirsadan/david-libre/releases/download/v${version}/DavidLibre_TTF_v1.001.zip";
              stripRoot = false;
              hash = "sha256-suzC7tc7UoVrS3hpOk2154WEWlXQcxD+hil0cMb/paw=";
            };
            installPhase = ''
              runHook preInstall
              install -m444 -Dt $out/share/fonts/truetype *.ttf
              runHook postInstall
            '';
            meta = with lib; {
              homepage = "https://github.com/meirsadan/david-libre";
              license = licenses.ofl;
              platforms = platforms.all;
            };
          })
          (stdenv.mkDerivation rec {
            pname = "linux-libertine";
            version = "5.3.0";
            src = pkgs.fetchzip {
              url = "https://downloads.sourceforge.net/project/linuxlibertine/linuxlibertine/5.3.0/LinLibertineTTF_5.3.0_2012_07_02.tgz";
              stripRoot = false;
              hash = "sha256-Az9neVss6ygRtnGdNtJRCYN2C2FlJPbvfNxfSxsbTRQ=";
            };
            installPhase = ''
              runHook preInstall
              install -m444 -Dt $out/share/fonts/truetype *.ttf
              runHook postInstall
            '';
            meta = with lib; {
              homepage = "https://libertine-fonts.org";
              license = licenses.ofl;
              platforms = platforms.all;
            };
          })
        ] else [ ])
        ++ cfg.fonts;
    };
    environment.systemPackages = cfg.fonts;
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
    systemd.services."my-fonts-setup-sudo" = {
      script = ''
        if [ -d "/usr/share/fonts" ]; then
          echo "";
        else
          mkdir -p /usr/share;
          ln -sf /run/current-system/sw/share/X11/fonts /usr/share/fonts;
        fi
      '';
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
      };
    };
  };
}


