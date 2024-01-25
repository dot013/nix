{ config, pkgs, lib, ... }:

let
  cfg = config.homelab;
  homelab-build = pkgs.writeShellScriptBin "homelab-build" ''
    flakeDir="${toString cfg.flakeDir}";
    gum="${pkgs.gum}/bin/gum"
    interactive="$1"
    shift 1;

    function rebuild() {

      local sleep_killed="false";
      local sleep_pid="$(ps -fu $USER | grep "sleep" | grep -v "grep" | awk '{print $2}')";

      while IFS= read -r LINE; do
        if [[ "$sleep_killed" == "false" ]]; then 
          kill -9 $sleep_pid; # I don't know to hide the message from this command :/
          sleep_killed="true";
        fi

        $gum log --structured --time timeonly --level info "$LINE"
      done < <(stdbuf -oL nixos-rebuild switch --flake "$flakeDir" "$@")

      if [[ "$sleep_killed" == "false" ]]; then 
        kill -9 $sleep_pid;
        sleep_killed="true";
      fi

      local gum_pid="$(ps -fu $USER | grep "/bin/gum" | grep -v "grep" | awk '{print $2}')";
    
      kill -9 $gum_pid; # it's kinda ugly this code in general, but whatever, at least the output is pretty
    }

    function spin() {
      sleep 1000;
      $gum spin --title "Activating build" -- sleep 1000;
    }

    if [[ "$interactive" == "true" ]]; then
      $gum log --structured --time timeonly --level info "Building homelab" command "nixos-rebuild switch --flake $flakeDir $@"
      rebuild "$@" & spin;
    else
      nixos-rebuild switch --flake "$flakeDir" "$@";
    fi
  '';
  homelab = pkgs.writeShellScriptBin "homelab" ''
    gum="${pkgs.gum}/bin/gum";
    interactive="true";

    command="$1";

    if [[ "$@" == *"--verbose"* ]]; then
      interactive="false";
    elif [[ "$1" == *"--not-interactive"* ]]; then
      interactive="false";
      shift 1;
      command="$1";
    fi

    if [[ "$command" == "build" ]]; then
      shift 1;
      sudo ${homelab-build}/bin/homelab-build "$interactive" "$@";
      
      if [[ "$interactive" == "true" && "$?" == 0 ]]; then
        $gum log --structured --time timeonly --level info "Reseting terminal in 5 seconds..."
        sleep 5
        reset
      fi
    fi
  '';
in
{
  imports = [
    ./forgejo.nix
  ];
  options.homelab = with lib; with lib.types; {
    enable = mkEnableOption "";
    flakeDir = mkOption {
      type = str;
    };
    storage = mkOption {
      type = path;
      default = /data/homelab;
      description = "The Homelab central storage path";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      homelab
    ];
  };
}
