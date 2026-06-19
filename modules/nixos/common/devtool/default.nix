{ pkgs, lib, config, ... }:
{
  config = lib.mkIf config.myModule.devtool {
    environment.systemPackages = with pkgs; [
      # Linux Kernel Build
      gnumake
      gcc
      binutils
      mtdutils
      jfsutils
      # reiserfsprogs removed from nixpkgs 2025-11-13 (ReiserFS v3 unmaintained).
      libxfs
      squashfsTools
      btrfs-progs
      pcmciaUtils
      quota
      ppp
      nfs-utils
      oprofile
      grub2
      mcelog
      openssl
      bc
      sphinx
      flex
      bison
      libelf
    ];
  };
}
