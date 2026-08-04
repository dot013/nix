{pkgs, ...}: {
  # Vesktop (Discord)
  programs.vesktop.enable = true;
  programs.vesktop.vencord = {
    settings = {
      autoUpdate = false;
      autoUpdateNotification = false;
      disableMinSize = true;
      enabledThemes = ["no-extra.css" "no-nitro.css"];
      notifyAboutUpdates = false;
      plugins = {
        CrashHandler.enabled = true;
        Dearrow.enabled = true;
        FakeNitro.enabled = true;
        FixYoutubeEmbeds.enabled = true;
        NoTypingAnimation.enabled = true;
        petpet.enabled = true;
        PinDMs.enabled = true;
        VoiceMessages.enabled = true;
        WebKeybinds.enabled = true;
        WebScreenShareFixes.enabled = true;
        YoutubeAdblock.enabled = true;
      };
    };
    themes = {
      "no-nitro" = pkgs.fetchurl {
        url = "https://code.capytal.cc/guz013/no-bullshit-discord.css/raw/branch/main/no-nitro.css";
        hash = "sha256-ouHW4KL+Jn5ERfFRcw7n15bWnzea7/lCLr4h0PsPQA8=";
      };
    };
  };
}
