inputs@{
  ...
}:

{
  x1carbon = import ./x1carbon/nixosConfiguration.nix inputs;
  tsuyoServer = import ./tsuyoServer/nixosConfiguration.nix inputs;
  raspi3bp = import ./raspi3bp/nixosConfiguration.nix inputs;
  wsl2 = import ./wsl2/nixosConfiguration.nix inputs;
}
