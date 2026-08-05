{pkgs, ...}: {
  programs.vivaldi.enable = true;
  programs.vivaldi.dictionaries = with pkgs.hunspellDictsChromium; [
    en_US
    (mkDictFromChromium {
      shortName = "pt-br";
      dictFileName = "pt-BR-3-0.bdic";
      shortDescription = "Portuguese (Brazillian)";
    })
  ];
  programs.vivaldi.extensions = [
    {id = "nglaklhklhcoonedhgnpgddginnjdadi";} # ActivityWatch
    {id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";} # Dark Reader
    {id = "enamippconapkdmgfgjchkhakpfinmaj";} # DeArrow
    {id = "oldceeleldhonbafppcapldpdifcinji";} # LanguageTool
    rec {
      id = "oladmjdebphlnjjcnomfhhbfdldiimaf"; # Libreredirect
      version = "3.3.0";
      crxPath = pkgs.fetchurl {
        url = "https://github.com/libredirect/browser_extension/releases/download/v${version}/libredirect-${version}.crx";
        hash = "sha256-3LDV2kv5Mvz1EBhM06L4QHg87ic5eZeEyWwSZorpC78=";
      };
    }
    {id = "edibdbjcniadpccecjdfdjjppcpchdlm";} # I Still Don't Care About Cookies
    {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # uBlock Origin
    {id = "mnjggcdmjocbbbhaepdhchncahnbgone";} # SponsorBlock
  ];
}
