{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libgpiod
    gcc
  ];
}
