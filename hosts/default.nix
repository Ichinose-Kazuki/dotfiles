inputs@{
  ...
}:

{
  tsuyoServer = import ./tsuyoServer/nixosConfiguration.nix inputs;
  rpi5 = import ./rpi5/nixosConfiguration.nix inputs;
  x1carbon = import ./x1carbon/nixosConfiguration.nix inputs;
}
