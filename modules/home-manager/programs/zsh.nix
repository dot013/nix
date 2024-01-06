{ inputs, config, pkgs, lib, ... }:

let
  cfg = config.zsh;
in
{
  options.zsh = {
    enable = lib.mkEnableOption "Enable Zsh shell";
    plugins = {
      suggestions.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      completion.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;
    programs.zsh.oh-my-zsh.enable = true;

    programs.zsh.enableAutosuggestions = lib.mkIf (cfg.plugins.suggestions.enable) true;
    programs.zsh.enableCompletion = lib.mkIf (cfg.plugins.completion.enable) true;
  };
}
