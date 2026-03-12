{pkgs, ...}: {
  programs.qutebrowser.greasemonkey = [
    # Youtube Adblocking
    (pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/afreakk/greasemonkeyscripts/refs/heads/master/youtube_adblock.js";
      hash = "sha256-AyD9VoLJbKPfqmDEwFIEBMl//EIV/FYnZ1+ona+VU9c=";
    })

    # Youtube Sponsorblock
    (pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/afreakk/greasemonkeyscripts/refs/heads/master/youtube_sponsorblock.js";
      hash = "sha256-nwNade1oHP+w5LGUPJSgAX1+nQZli4Rhe8FFUoF5mLE=";
    })

    # Reddit adblock
    (pkgs.fetchurl {
      url = "https://github.com/afreakk/greasemonkeyscripts/raw/refs/heads/master/reddit_adblock.js";
      hash = "sha256-KmCXL4GrZtwPLRyAvAxADpyjbdY5UFnS/XKZFKtg7tk=";
    })

    # Pinterest adblock
    (pkgs.writeText "pinterest_adblock.js" ''
      // ==UserScript==
      // @name         remove ads from pinterest
      // @version      1.0.0
      // @author       guz
      // @match        *://*.pinterest.com/*
      // ==/UserScript==

      const removeShit = () => {
          document.querySelectorAll('[data-grid-item]:has([title="Promoted by"])').forEach((e) => e.remove());
          document.querySelectorAll('[data-grid-item]:has([data-test-id="oneTapPromotedPin"])').forEach((e) => e.remove());
          document.querySelectorAll('[data-grid-item]:has([aria-label="Product Pin"])').forEach((e) => e.remove());
          // document.querySelectorAll('[data-grid-item]:has-text(ideas you might love)').forEach((e) => e.remove());
          // document.querySelectorAll('[data-grid-item]:has-text(Seaches to try)').forEach((e) => e.remove());
      };
      (trySetInterval = () => {
          window.setInterval(removeShit, 1000);
      })();
    '')

    # Privacy Redirector
    (pkgs.substitute {
      src = pkgs.fetchurl {
        url = "https://github.com/dybdeskarphet/privacy-redirector/raw/refs/heads/main/privacy-redirector.user.js";
        hash = "sha256-xj36+/3coiStIxftWCJUWHokSEmr+YRLOTktbmn5TkU=";
      };
      substitutions = [
        # ON-OFF (Redirection / Farside)
        "--replace"
        "pinterest = [true, true]"
        "pinterest = [false, false]"
        "--replace"
        "tumblr = [true, false]"
        "tumblr = [false, false]"
        "--replace"
        "wikipedia = [true, false]"
        "wikipedia = [false, false]"
        "--replace"
        "youtube = [true, false]"
        "youtube = [false, false]"
        "--replace"
        "instagram = [true, true]"
        "instagram = [false, false]"
      ];
    })

    # # Aternos Anti-Anti-Adblock
    # (pkgs.fetchurl {
    #   url = "https://gist.github.com/DvilMuck/f2b14f3f65e8f22974d781277158f82a/raw/66a0d8d9dd598fc516c3c9d9bbf6ef3f0f6a7a1e/aternosAntiAntiadblock.user.js";
    #   hash = "sha256-PBFCt9o22D7WAN8S6C2BnLKgG3J5zZ/mWbWspCKcm6k=";
    # })
    #
    # # Aternos block tracking
    # (pkgs.fetchurl {
    #   url = "https://gist.github.com/DvilMuck/f2b14f3f65e8f22974d781277158f82a/raw/66a0d8d9dd598fc516c3c9d9bbf6ef3f0f6a7a1e/aternosBlockTracking.user.js";
    #   hash = "sha256-GDDx3gbvh28qiB3Gi61k/pdM11wJhcV7dwCRGNvq30c=";
    # })
  ];
}
