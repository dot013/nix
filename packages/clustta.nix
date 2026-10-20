{
  lib,
  buildGo127Module,
  fetchFromGitHub,
}:
buildGo127Module rec {
  pname = "clustta";
  version = "0.4.40";
  src = fetchFromGitHub {
    owner = "eaxum";
    repo = "clustta-studio";
    rev = "v${version}";
    hash = "sha256-NQf+9nIn22eaTjdxMTBxXRDZT/sjKR7717vFcoxSidA=";
  };
  subPackages = ["cmd/studio_server"];
  vendorHash = "sha256-xb+5kM9eJE1JC3GbhBRK6X59WwVmPNx5SPEN1OAMkxY=";

  ldflags = [
    "-s"
    "-w"
    "-X"
    "main.Version=${version}"
  ];

  env.CGO_ENABLED = 1;

  meta = with lib; {
    license = licenses.agpl3Only;
    mainProgram = "studio_server";
  };
}
