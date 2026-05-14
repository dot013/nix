{
  fetchFromGitHub,
  rustPlatform,
  lib,
  ...
}:
with lib;
  rustPlatform.buildRustPackage rec {
    pname = "playit-agent";
    version = "0.17.1";

    src = cleanSource (fetchFromGitHub {
      owner = "playit-cloud";
      repo = "playit-agent";
      rev = "v${version}";
      hash = "sha256-kT7NLUcgGM/hxwK4PUDZ71PtYJqjR8i4yj/LhbXX1i0=";
    });
    cargoLock = {
      lockFile = "${src}/Cargo.lock";
    };

    strictDeps = true;
    # Requires internet access
    doCheck = false;

    meta = {
      description = "The playit program";
      license = licenses.bsd2;
      mainProgram = "playit-cli";
    };
  }
