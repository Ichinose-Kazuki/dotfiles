{ pkgs, config, ... }:

{
  # Zsh and Bash
  programs.zsh = {
    enable = true;
    histSize = 10000000;
    # Copied from the following URL and modified:
    # https://discourse.nixos.org/t/using-zsh-with-grml-config-and-nix-shell-prompt-indicator/13838
    interactiveShellInit = ''
      # Note that loading grml's zshrc here will override NixOS settings such as
      # `programs.zsh.histSize`, so they will have to be set again below.
      source ${pkgs.grml-zsh-config}/etc/zsh/zshrc

      # Increase history size.
      HISTSIZE=${builtins.toString config.programs.zsh.histSize}

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
      zstyle ':prompt:grml:left:setup' items rc nix-shell-indicator change-root user path vcs percent

      # Set locale to English
      LANG=en_US.UTF-8

      # keybindings
      bindkey '^H' backward-delete-word # Ctrl+Backspace to delete a word on the left
      bindkey '^[[3;5~' kill-word # Ctrl+Delete to delete a word on the right
    '';
    promptInit = ""; # otherwise it'll override the grml prompt
  };
}
