{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Linux Kernel Build
    gnumake
    gcc
    binutils
    mtdutils
    jfsutils
    reiserfsprogs
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
}
