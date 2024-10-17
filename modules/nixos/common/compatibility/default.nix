{ config
, pkgs
, ...
}:

{
  services.envfs.enable = true;

  programs.nix-ld = { # Necessary on vscode remote host and to run unpatched binaries.
    enable = true;
  };
}
