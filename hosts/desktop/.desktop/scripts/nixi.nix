{ pkgs, ... }:

let
  nixi = pkgs.writeShellScriptBin "nixi" ''
    # npm-like command for nix
    function nix-shell() {
      local pkg="$1"
      nix shell "nixpkgs#$pkg"
    }
    nix-shell $1
  '';
in
{
  home.packages = [
    nixi
  ];
}


