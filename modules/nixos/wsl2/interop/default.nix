{ ... }:

{
  # Allow foreign binaries to run on NixOS.
  # https://nix-community.github.io/NixOS-WSL/how-to/vscode.html
  programs.nix-ld = {
    enable = true;
    # package = pkgs.nix-ld-rs; (nix-ld-rs has been merged to nix-ld.)
  };
}
