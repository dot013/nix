{
  lib,
  config,
  pkgs,
  ...
}: let
  ewwDir = "${config.xdg.configHome}/eww";

  eww-get-active-workspace = pkgs.writeShellScriptBin "eww-get-active-workspace" ''
    hyprctl="${pkgs.hyprland}/bin/hyprctl"
    jq="${pkgs.jq}/bin/jq"
    socat="${pkgs.socat}/bin/socat"

    $hyprctl monitors -j |
      $jq '.[] | select(.focused) | .activeWorkspace.id'

    $socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - |
      stdbuf -o0 awk -F '>>|,' -e '/^workspace>>/ {print $2}' -e '/^focusedmon>>/ {print $3}'
  '';

  eww-volume = pkgs.writeShellScriptBin "eww-volume" ''
    pulsemixer="${pkgs.pulsemixer}/bin/pulsemixer"

    sink="$(echo $($pulsemixer -l | grep 'Default' | grep 'sink-' | awk '{print $3}') | rev | cut -c 2- | rev)"
    function="$1"
    value="$2"

    if [[ "$function" == "set" ]]; then
      $pulsemixer --id "$sink" --set-volume "$value"
      echo "0"
    elif [[ "$function" == "get" ]]; then
      echo "$($pulsemixer --id "$sink" --get-volume | awk '{print $1}')"
    elif [[ "$function" == "label" ]]; then
      echo "$($pulsemixer --id "$sink" --get-mute | awk '{if($1>0) print "󰖁"; else print "󰕾"}')"
    fi
  '';

  eww-weather = pkgs.writeShellScriptBin "eww-weather" ''
    curl="${pkgs.curl}/bin/curl"
    jq="${pkgs.jq}/bin/jq"

    lat="$(cat /run/secrets/lat)"
    lon="$(cat /run/secrets/lon)"

    res="$($curl -s "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,precipitation,wind_speed_10m,rain")"

    temperature="$(echo $res | $jq .current.temperature_2m)"
    wind="$(echo $res | $jq .current.wind_speed_10m)"
    precipitation="$(echo $res | $jq .current.precipitation)"
    rain="$(echo $res | $jq .current.rain)"

    if [[ "$1" == "--temperature" ]]; then
    	echo $temperature
    elif [[ "$1" == "--wind" ]]; then
    	echo $wind
    elif [[ "$1" == "--precipitation" ]]; then
    	echo $precipitation
    elif [[ "$1" == "--rain" ]]; then
    	echo $rain
    fi
  '';
  eww-battery = pkgs.writeShellScriptBin "eww-battery" ''
    BAT="$(ls /sys/class/power_supply | grep BAT | head -n 1)"
    cat "/sys/class/power_supply/$BAT/capacity"
  '';
in {
  imports = [];
  options = {};
  config = {
    programs.eww.package = pkgs.eww;

    home.file."${ewwDir}/eww.yuck".source = ./eww.yuck;
    home.file."${ewwDir}/eww.scss".source = ./eww.scss;

    home.file."${ewwDir}/vars.yuck".text = ''
      (deflisten active-workspace :initial "1"
      "${eww-get-active-workspace}/bin/eww-get-active-workspace")

      (defpoll volume :interval "1s"
      "${eww-volume}/bin/eww-volume get")

      (defpoll volume-label :interval "1s"
      "${eww-volume}/bin/eww-volume label")

      (defvar volume-set "${eww-volume}/bin/eww-volume set {}")
      (defvar volume-toggle "${pkgs.pulsemixer}/bin/pulsemixer --toggle-mute")

      (defpoll temperature :interval "15m" :initial "00.0"
      "${eww-weather}/bin/eww-weather --temperature")
      (defpoll wind :interval "15m" :initial "00.0"
      "${eww-weather}/bin/eww-weather --wind")
      (defpoll precipitation :interval "15m" :initial "00.0"
      "${eww-weather}/bin/eww-weather --precipitation")
      (defpoll rain :interval "15m" :initial "00.0"
      "${eww-weather}/bin/eww-weather --rain")

      (defpoll battery :interval "1s"
      "${eww-battery}/bin/eww-battery")
    '';

    home.file."${ewwDir}/vars.scss".text = ''
      $color-accent: #${config.desktop.colors.accent};
      $foreground: rgba(#${config.colorScheme.palette.base03}, 1);
      $background: rgba(#${config.colorScheme.palette.base00} , 1);

      $shadow: 2px 2px 2px rgba(0, 0, 0, 0.2);
      $border-radius: 5px;

      @mixin box-style {
        border-radius: $border-radius;
        box-shadow: $shadow;
        background-color: $background;
      }
    '';
  };
}
