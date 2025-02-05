{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.dot013-nvim.homeManagerModules.neovim
  ];

  home.sessionVariables = {
    # EDITOR = "nvim"; # Default editor, already defined by dot013-nvim
    SHELL = lib.getExe config.programs.zsh.package;
    TERMINAL = lib.getExe config.programs.ghostty.package;
  };

  # Local development shells
  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;
  programs.direnv.nix-direnv.enable = true;

  # Ghostty (Terminal)
  programs.ghostty.enable = true;
  programs.ghostty.enableZshIntegration = true;

  # Neovim (Editor)
  # programs.neovim.enable = true; # Already enabled by dot013-nvim

  # Git
  programs.git.enable = true;
  programs.git.userEmail = "contact@guz.one";
  programs.git.userName = "Gustavo \"Guz\" L de Mello";
  programs.git.extraConfig = {
    credential.helper = "store";
    http.proxy = "";
    https.proxy = "";
    signing.singByDefault = true;
  };

  # Better git diff
  programs.git.delta.enable = true;

  # GPG Keyring
  programs.gpg.enable = true;
  programs.gpg.mutableKeys = true;
  programs.gpg.mutableTrust = true;

  services.gpg-agent.enable = true;
  services.gpg-agent.enableZshIntegration = true;
  services.gpg-agent.defaultCacheTtl = 3600 * 24;
  services.gpg-agent.pinentryPackage = pkgs.pinentry-gtk2;

  # Git TUI
  programs.lazygit.enable = true;
  programs.lazygit.settings = {
    git.paging.colorArg = "always";
    git.paging.pager = "${lib.getExe config.programs.git.delta.package} --dark --paging=never";
  };

  # Shell decoration
  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;

  # SSH
  programs.ssh.enable = true;
  programs.ssh.matchBlocks = {
    "battleship" = {
      hostname = "battleship";
      user = "${config.home.username}";
      identitiesOnly = true;
      identityFile = "${config.home.homeDirectory}/home/battleship";
      extraOptions = {RequestTTY = "yes";};
    };
    "fithter" = {
      hostname = "fighter";
      user = "${config.home.username}";
      identitiesOnly = true;
      identityFile = "${config.home.homeDirectory}/home/fighter";
      extraOptions = {RequestTTY = "yes";};
    };
  };

  # Yazi (File manager)
  programs.yazi.enable = true;
  programs.yazi.enableZshIntegration = true;
  programs.yazi.settings = {
    manager = {
      show_hidden = true;
      show_symlink = true;

      sort_by = "natural";
      sort_dir_first = true;
      sort_sensitive = false;
      sort_translit = true;

      linemode = "size";
    };
  };
  home.file."${config.xdg.configHome}/yazi/init.lua".text = ''
    -- Add username and hostname in header
    -- https://yazi-rs.github.io/docs/tips#username-hostname-in-header
    Header:children_add(function()
      if ya.target_family() ~= "unix" then
        return ""
      end
      return ui.Span(ya.user_name() .. "@" .. ya.host_name() .. ":"):fg("blue")
    end, 500, Header.LEFT)

    -- Add user and group owner of file in status line
    -- https://yazi-rs.github.io/docs/tips#user-group-in-status
    Status:children_add(function()
      local h = cx.active.current.hovered
      if h == nil or ya.target_family() ~= "unix" then
        return ""
      end

      return ui.Line({
        ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
        ":",
        ui.Span(ya.user_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
        " ",
      })
    end, 500, Status.RIGHT)
  '';
  # Zellij (Terminal multiplexer)
  programs.zellij.enable = true;
  programs.zellij.enableZshIntegration = true;

  # Default shell
  programs.zsh.enable = true;
  programs.zsh.autosuggestion.enable = true;
  programs.zsh.enableCompletion = true;
}
