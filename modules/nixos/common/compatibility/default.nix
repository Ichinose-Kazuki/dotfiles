{ config
, pkgs
, ...
}:

{
  environment.systemPackages = with pkgs; [
    nix-ld # Necessary on vscode remote host and to run unpatched binaries. 
  ];
}
