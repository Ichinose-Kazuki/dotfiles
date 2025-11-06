{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;
    # To override commandLineArgs: (vscode.override (p: { commandLineArgs = previous.commandLineArgs + " --new_arg"; })).fhs;
    # Integrated terminal sudo hacks: let systemd-run start zsh, or use run0 instead. (https://discourse.nixos.org/t/sudo-does-not-work-from-within-vscode-fhs/14227)
  };
}
