{
  symlinkJoin,
  makeWrapper,
  pkgs,
  lib,
  starship ? pkgs.starship,
}:
symlinkJoin ({
    paths = [starship];
    nativeBuildInputs = [makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/starship \
        --set-default 'STARSHIP_CONFIG' '${./config.toml}'
    '';
  }
  // {inherit (starship) name pname meta;})
