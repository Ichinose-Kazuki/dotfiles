{ ... }:

{
  # temporary patch. https://github.com/NixOS/nixpkgs/issues/312452
  systemd.services.systemd-vconsole-setup = {
    unitConfig = {
      After = "local-fs.target";
    };
  };
  console.earlySetup = false;
  boot.initrd.systemd.enable = false;
}
