{ pkgs, ... }:

let
  nixx = pkgs.writeShellScriptBin "nixx" ''
    # npx-like command for nix
    function nix-run() {
      local pkg="$1"
        nix run "nixpkgs#$pkg"
    }
    nix-run $1
  '';
in
{
  home.packages = [
    nixx
  ];
}
