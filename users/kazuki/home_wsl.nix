{ config
, pkgs
, lib
, inputs
, host
, ...
}:

{
  imports = with inputs; [
    self.homeManagerModules.kazuki.common
    self.homeManagerModules.kazuki.wsl2
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "kazuki";
  home.homeDirectory = "/home/kazuki";
  home.language.base = "ja_JP.UTF-8";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # kdePackages.gwenview

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/kazuki/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "vim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs = {
    fzf.enable = true;
    # vscode = {
    #   enable = true;
    #   package = pkgs.vscode-fhs;
    # };
    zoxide = {
      enable = true;
      options = [
        "--cmd"
        "cd"
      ];
    };
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    bash = {
      enable = true;
      profileExtra = "source ${config.home.homeDirectory}/.profile.manual";
      initExtra = "source ${config.home.homeDirectory}/.bashrc.manual";
    };
    carapace.enable = true;
    zsh = {
      enable = true;
      autocd = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = lib.mkMerge [
        # bat
        (lib.mkIf config.programs.bat.enable {
          cat = "bat";
        })

        # lsd
        (lib.mkIf config.programs.lsd.enable {
          ls = "lsd";
          tree = "lsd --tree";
        })
        {
          ll = "ls -l";
          la = "ls -la";
          l = "ls";
        }
      ];
      history.size = 10000000;
      # Copied from the following URL and modified:
      # https://discourse.nixos.org/t/using-zsh-with-grml-config-and-nix-shell-prompt-indicator/13838 
      initExtraFirst = ''
        # Note that loading grml's zshrc here will override NixOS settings such as
        # `programs.zsh.histSize`, so they will have to be set again below.
        source ${pkgs.grml-zsh-config}/etc/zsh/zshrc

        # Increase history size.
        HISTSIZE=${builtins.toString config.programs.zsh.history.size}

        # Prompt modifications.
        #
        # In current grml zshrc, changing `$PROMPT` no longer works,
        # and `zstyle` is used instead, see:
        # https://unix.stackexchange.com/questions/656152/why-does-setting-prompt-have-no-effect-in-grmls-zshrc

        # Disable the grml `sad-smiley` on the right for exit codes != 0;
        # it makes copy-pasting out terminal output difficult.
        # Done by setting the `items` of the right-side setup to the empty list
        # (as of writing, the default is `items sad-smiley`).
        # See: https://bts.grml.org/grml/issue2267
        zstyle ':prompt:grml:right:setup' items

        # Add nix-shell indicator that makes clear when we're in nix-shell.
        # Set the prompt items to include it in addition to the defaults:
        # Described in: http://bewatermyfriend.org/p/2013/003/
        function nix_shell_prompt () {
          REPLY=''${IN_NIX_SHELL+"(nix-shell) "}
        }
        grml_theme_add_token nix-shell-indicator -f nix_shell_prompt '%F{magenta}' '%f'

        # grml prompt customization with "zstyle" command
        # To see available options: $ prompt -h grml
        zstyle ':prompt:grml:left:items:path' pre ' %F{245}'
        zstyle ':prompt:grml:left:items:path' post '%f'
        zstyle ':prompt:grml:left:items:percent' pre '%F{245}'
        zstyle ':prompt:grml:left:items:percent' post '%f'

        # Don't show the vcs info and nix-shell-indicator in a vscode terminal
        if [[ $(printenv | grep -c "VSCODE_") -gt 0 ]]; then
          zstyle ':prompt:grml:left:setup' items rc change-root user path percent
        else
          zstyle ':prompt:grml:left:setup' items rc nix-shell-indicator change-root user path vcs percent
        fi

        # Set locale to English
        LANG=en_US.UTF-8
      '';
    };
  };

  # Internationalization
  # i18n = {
  #   glibcLocales = pkgs.glibcLocales.override {
  #     allLocales = false;
  #     locales = [ "ja_JP.UTF-8/UTF-8" ];
  #   };
  # };
}
