{
  pkgs,
  wrapPackage,
  # Package
  lynx ? pkgs.lynx,
}:
wrapPackage {
  inherit pkgs;
  package = lynx;
  args = ["https://lite.duckduckgo.com"];
}
