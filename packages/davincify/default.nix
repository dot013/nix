{
  pkgs,
  lib,
  ...
}:
pkgs.writeShellScriptBin "davincify" ''
  function ffmpeg() { ${lib.getExe pkgs.ffmpeg} "$@"; }
  ${builtins.readFile ./davincify.sh}
''
