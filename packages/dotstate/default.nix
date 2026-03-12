{pkgs, ...}:
with pkgs;
  writers.writeBashBin "dotstate" {
    makeWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      "${lib.makeBinPath [
        socat
        jq
      ]}"
    ];
  } (builtins.readFile ./dotstate.sh)
