{
  config,
  lib,
  ...
}:
with lib; {
  options.services.cloudflared = {
    tunnels = mkOption {
      type = with types;
        attrsOf (submodule
          ({...}: {
            options.caddy-domain = mkOption {
              type = nullOr str;
              default = null;
            };
          }));
      apply = tunnels:
        mapAttrs (n: v: let
          domain = v.caddy-domain;
        in
          if isNull domain
          then v
          else
            v
            // {
              ingress =
                (pipe config.services.caddy.virtualHosts [
                  (mapAttrs' (n: v: let
                    domainPort = splitString ":" n;
                    domain = elemAt domainPort 0;
                    port =
                      if (length domainPort) > 1
                      then elemAt domainPort 1
                      else null;
                  in
                    nameValuePair domain port))
                  (filterAttrs (n: v: !(isNull v) && hasSuffix domain n))
                  (mapAttrs (n: v: {service = "http://localhost:${v}";}))
                ])
                // v.ingress;
            })
        tunnels;
    };
  };
}
