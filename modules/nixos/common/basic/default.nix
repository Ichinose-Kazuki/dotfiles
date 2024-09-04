{ config, lib, pkgs, inputs, ... }:

{
  # Nix settings
  nix.settings = {
    experimental-features = [
      "flakes"
      "nix-command"
    ];
  };

  # make sure less supports utf-8 character
  environment.sessionVariables.LESSCHARSET = "utf-8";
  
  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Select internationalisation properties.
  i18n.defaultLocale = "ja_JP.UTF-8";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kazuki = {
    isNormalUser = true;
    description = "Kazuki Ichinose";
    hashedPassword = "$6$SJ579N5INL5GkkFX$GaNRYmajPpOXqW7dSxtV2wRX/ikTyOMVUWk1piqMKxMXvJvc2ow07ZsVWk3zatbCi1WwPRn4TDVV9vZXHQ5e8/";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "input" "docker" ];
    packages = with pkgs; [
      nixpkgs-fmt
    ];
    shell = pkgs.zsh;
  };
  users.mutableUsers = false;
  users.users.root.shell = pkgs.zsh;

  
  # Comma
  programs.nix-index-database.comma.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # ! Attribute set with the same name in multiple modules are merged automatically.
  # ! c.f. https://discourse.nixos.org/t/several-environment-systempackages-in-configuration-nix/39226/3
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    git
    wget
    perl
    lshw
    usbutils
    pciutils
    ripgrep
  ];
}
