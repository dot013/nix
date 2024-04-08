{
  config,
  lib,
  pkgs,
  ...
}:
with builtins; let
  cfg = config.programs.wezterm;
  jsonFormat = pkgs.formats.json {};
  toLua = with lib.strings;
    v:
      if isList v
      then "{ ${concatMapStringsSep ", " (i: toLua i) v} }"
      else if isAttrs v
      then "\{ ${concatStringsSep ", " (attrValues (mapAttrs (n: a: "${n} = ${toLua a}") v))} \}"
      else if isNull v
      then "nil"
      else if isBool v
      then
        if v
        then "true"
        else "false"
      else if isInt v
      then toString v
      else if isString v && hasPrefix "lua " v
      then "${substring 4 (stringLength v) v}"
      else "\"${toString v}\"";
  configInLua = pkgs.writeText "nih-wezterm-generated-config" ''
    local wezterm = require("wezterm");

    local nih_generated_config = {};
    ${concatStringsSep "\n" (attrValues (mapAttrs
      (n: v: "nih_generated_config.${n} = ${toLua v};")
      cfg.config))}

    local function extra_config()
      ${cfg.extraConfig}
    end

    for k,v in pairs(extra_config()) do nih_generated_config[k] = v end

    return nih_generated_config;
  '';
  prettyConfig = pkgs.runCommand "nih-wezterm-pretty-config" {config = configInLua;} ''
    echo "Nih's Wezterm configuration file builder";
    echo "input file: $config";
    echo "output file: $out";
    echo ""
    echo "Formatting config file with Stylua"
    cat $config | ${pkgs.stylua}/bin/stylua - > $out
    echo ""
    echo "Checking erros with luacheck"
    ${pkgs.luajitPackages.luacheck}/bin/luacheck \
      --no-max-line-length \
      --no-unused \
      "$out";
  '';
in {
  imports = [];
  options.programs.wezterm = with lib;
  with lib.types; {
    config = mkOption {
      type = submodule ({...}: {
        freeformType = jsonFormat.type;
      });
      default = {};
    };
  };
  config = with lib;
    mkIf cfg.enable {
      programs.wezterm = {
        enableBashIntegration = mkDefault config.programs.bash.enable;
        enableZshIntegration = mkDefault config.programs.zsh.enable;
      };

      xdg.configFile."wezterm/wezterm.lua".source = prettyConfig;
    };
}
