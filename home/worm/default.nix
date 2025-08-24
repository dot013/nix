{
  self,
  lib,
  pkgs,
  osConfig,
  ...
}: {
  home.username = "guz";
  home.homeDirectory = "/home/guz";

  imports = [
    self.homeManagerModules.devkit
  ];

  devkit.enable = true;
  devkit.git.wrapper = lib.mkIf (osConfig.context.job) (pkgs.writeShellScriptBin "git-envs" ''
    source ${osConfig.sops.secrets."guz/git-envs".path}
    "$@"
  '');

  # The *state version* indicates which default
  # settings are in effect and will therefore help avoid breaking
  # program configurations. Switching to a higher state version
  # typically requires performing some manual steps, such as data
  # conversion or moving files.
  home.stateVersion = "24.11";
}
