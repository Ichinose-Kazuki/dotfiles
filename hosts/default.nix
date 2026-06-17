inputs@{
  ...
}:

{
  tsuyoServer = import ./tsuyoServer/nixosConfiguration.nix inputs;
  raspi3bp = import ./raspi3bp/nixosConfiguration.nix inputs;
  rpi5 = import ./rpi5/nixosConfiguration.nix inputs;
  wsl2 = import ./wsl2/nixosConfiguration.nix inputs;
  # x1carbon is defined directly in flake.nix (Dendritic pilot).
}
