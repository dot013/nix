{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.minecraft-servers;
in {
  imports = [../services/minecraft-servers.nix];
  options.profiles.minecraft-servers = with lib; {
    enable = mkEnableOption "";
  };
  config = let
    optimizationMods = builtins.attrValues {
      AlternateCurrent = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/r0v8vy1s/versions/CFNRLnDw/alternate-current-mc1.20-1.8.0-beta.3.jar";
        sha256 = "130k9ay8hylbv2ijzj5n9951ww2lxyqrykazvr8l3yf1dbm0n56r";
      };
      /*
          BetterMaps = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/JX1fvBwM/versions/SSxJn7Q3/bettermaps-mc1.20-0.5.2.jar";
      sha256 = "0aps89kxx98xhmya4ljy3h3dhni88wv697vh7ipg3vzfxhqyfj9p";
      };
      */
      CCME = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/VSNURh3q/versions/1jjyJyVe/c2me-fabric-mc1.20.6-0.2.0+alpha.11.95.jar";
        sha256 = "0ja97jv4x1xhm1nmpq661qf641zv314zzdp7q9d0wzfp712am0dc";
      };
      Chunky = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/fALzjamp/versions/ZrmnYk7q/Chunky-1.4.10.jar";
        sha256 = "098gg5s02c5lnz9y85vja9z17cmkaidf8fr99drrym5z1n3d48jf";
      };
      DisablePortalChecks = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/uOzKOGGt/versions/zW17oIr0/disableportalchecks-1.0.0.jar";
        sha256 = "1zq535nb6zv22plvz3p6ykh02skng6wjjzsalm1qmlidj22r8j40";
      };
      FabricApi = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/191HCCtF/fabric-api-0.98.0+1.20.6.jar";
        sha256 = "09p29f4333mnwigs7v307xhli99n51qg7prkkp9yfm9pwnvv26q3";
      };
      FasterRandom = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/RfFxanNh/versions/I8jy69I9/fasterrandom-4.1.0.jar";
        sha256 = "0hwxbkic4mwjl3sqm9hsl8xvf96qk87ah1njl7pnqpam720zl0i3";
      };
      Icterine = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/7RvRWn6p/versions/W7L89aQM/Icterine-fabric-1.20.3-4-1.3.0.jar";
        sha256 = "15vv2xqd6gzvckr3wxgisz02x9d938cgg2ncc2gnd3m6k3l6l5w5";
      };
      Lithium = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/bAbb09VF/lithium-fabric-mc1.20.6-0.12.3.jar";
        sha256 = "03fikawl6rw14gkzz74k7zv1cf9m0l9am12l2wmjf8mm0a9dmp9l";
      };
      MemoryLeakFix = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/NRjRiSSD/versions/5xvCCRjJ/memoryleakfix-fabric-1.17+-1.1.5.jar";
        sha256 = "1pmdllflr2mjjh2r3v8lyz8rxg0ncq8m9r15vl89f09f4vbk7b5q";
      };
      Noisium = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/KuNKN7d2/versions/lT2Jvcwv/noisium-fabric-2.1.0+mc1.20.5-1.20.6.jar";
        sha256 = "0bawxlrph66jladb9w1b20qn7av6az45nfn4bnggcygza35r0mrj";
      };
      NoKebab = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/y82xHklI/versions/t1haYknB/no-kebab-1.3.0+1.20.6.jar";
        sha256 = "1xks224cls95jnfhk54plnsmb1x4bb0llr17w1rwbbn6rx66p6gi";
      };
      ModernFix = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/nmDcB62a/versions/xlt4bcjj/modernfix-fabric-5.17.3+mc1.20.6.jar";
        sha256 = "1sdbv2a3zb1j481g2318vfaxd5hlx0h5fl7azl3j46095422yw93";
      };
      ServerCode = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/4WWQxlQP/versions/MiqvHRzE/servercore-fabric-1.5.1+1.20.5.jar";
        sha256 = "1vhb3dik4vancgsgm0ldmgx6qlsw0iiqlcq8gy0ifxmjmm1sin6f";
      };
      Slumber = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/ksm6XRZ9/versions/mPf1P26X/slumber-1.2.0.jar";
        sha256 = "1chp2wkjcmxi4apry1fkml3n7k4x2sjwc7dx9qjklqpcw4gbn7s7";
      };
      ThreadTweak = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/vSEH1ERy/versions/BtMMYDAh/threadtweak-fabric-1.20.6-0.1.3.jar";
        sha256 = "12nyln487bsn4gvlynzw0samds8mxi02bkxb9jdl9x0yy16pbrfh";
      };
      VeryManyPlayer = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/wnEe9KBa/versions/83ET13o3/vmp-fabric-mc1.20.6-0.2.0+beta.7.155-all.jar";
        sha256 = "039adzcpl9bx4h2gsl399b97vsi0h3b33421jbsl603rld6cgz88";
      };
    };
  in
    with lib;
      mkIf cfg.enable {
        services.minecraft-servers.enable = true;
        services.minecraft-servers.eula = true;
        services.minecraft-servers.openFirewall = true;

        networking.firewall.allowedTCPPorts = [25565];

        services.minecraft-servers.servers.survival = {
          enable = true;
          restart = "no";
          serverProperties = {
            server-port = 25565;
          };
          package = pkgs.fabricServers.fabric-1_20_6.override {};
          symlinks = {
            mods = pkgs.linkFarmFromDrvs "mods" optimizationMods;
          };
        };
      };
}
