{
  pkgs,
  lib,
  ...
}:
pkgs.writeShellScriptBin "untrack" ''
  function exitftool() { ${lib.getExe pkgs.exiftool} "$@"; }
  ${builtins.readFile ./untrack.sh}
''
