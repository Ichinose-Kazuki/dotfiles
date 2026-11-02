{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Linux Kernel Build
    gnumake
    gcc
    binutils
    mtdutils
    jfsutils
    libxfs
    squashfsTools
    btrfs-progs
    pcmciautils
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
