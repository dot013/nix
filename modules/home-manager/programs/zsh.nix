{ inputs, config, pkgs, lib, ... }:

let
  cfg = config.zsh;
in
{
  options.zsh = with lib; with lib.types; {
    enable = mkEnableOption "Enable Zsh shell";
    plugins = {
      suggestions.enable = mkOption {
        type = bool;
        default = true;
      };
      completion.enable = mkOption {
        type = bool;
        default = true;
      };
    };
    extraConfig = {
      init = mkOption {
        type = lines;
        default = "";
      };
      beforeComp = mkOption {
        type = lines;
        default = "";
      };
      first = mkOption {
        type = lines;
        default = "";
      };
    };
    loginExtra = mkOption {
      type = lines;
      default = "";
    };
    logoutExtra = mkOption {
      type = lines;
      default = "";
    };
    variables = mkOption {
      type = attrsOf str;
      default = { };
    };
  };
  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      oh-my-zsh.enable = true;

      loginExtra = cfg.loginExtra;
      logoutExtra = cfg.logoutExtra;

      initExtra = cfg.extraConfig.init;
      initExtraBeforeCompInit = cfg.extraConfig.beforeComp;
      initExtraFirst = cfg.extraConfig.first;

      localVariables = cfg.variables;

      enableAutosuggestions = lib.mkIf (cfg.plugins.suggestions.enable) true;
      enableCompletion = lib.mkIf (cfg.plugins.completion.enable) true;
    };
  };
}
