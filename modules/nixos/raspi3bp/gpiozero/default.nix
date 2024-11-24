{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (python312.withPackages
      (p: with p; [
        gpiozero
      ]))
  ];
}
