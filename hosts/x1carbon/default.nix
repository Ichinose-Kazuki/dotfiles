# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = with inputs; [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    nix-index-database.nixosModules.nix-index
    disko.nixosModules.disko
    ./disko.nix
    self.nixosModules.common
    self.nixosModules.x1carbon
  ];

  # avoid inputs of this flake from being garbage-collected.
  system.extraDependencies =
    let
      collectFlakeInputs =
        input:
        [ input ] ++ builtins.concatMap collectFlakeInputs (builtins.attrValues (input.inputs or { }));
    in
    builtins.concatMap collectFlakeInputs (builtins.attrValues inputs);

  # Enable builds for rpi.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "x1carbon"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  mySecrets.envFiles = [
    {
      name = "network-manager.env";
      vars = [
        "OPENROAMING_ID"
        "OPENROAMING_PW"
        "UHOHOI_PSK"
      ];
      comment = "Run `systemctl restart restart NetworkManager-ensure-profiles.service` after every edit";
    }
  ];

  networking.networkmanager = {
    enable = true;

    ensureProfiles = {
      environmentFiles = [
        "/etc/my-secrets/network-manager.env"
      ];

      # START_Bunkyo_WiFi で Android 用プロファイルをダウンロードし、base64 デコードを繰り返して以下の設定値を取得。
      # identity と password はデコード後の XML ファイルにある。password は記載されたものをさらにデコードしたものを入力。
      profiles.Bunkyo_Free_Wi-Fi00 = {
        connection = {
          id = "Bunkyo_Free_Wi-Fi00";
          type = "wifi";
        };

        wifi = {
          mode = "infrastructure";
          ssid = "Bunkyo_Free_Wi-Fi00";
        };

        wifi-security = {
          key-mgmt = "wpa-eap";
        };

        "802-1x" = {
          ca-cert = "/etc/ssl/certs/ca-certificates.crt"; # なんか profile についてきた ca-cert は使えなかったが、東京都の Free WiFi は Let's Encrypt を使っている？らしく、システム内蔵の ca-cert で OK. なお、システム内蔵のパスをなぜかこのように指定しないといけない。デフォルト値ではファイル読み取りエラー？になる。
          domain-suffix-match = "openroaming.air-compass.net";
          eap = "ttls;";
          phase2-auth = "mschapv2";
          # identity と password は password manager に保存済み。Google でログインして生成した。
          identity = "$OPENROAMING_ID";
          password = "$OPENROAMING_PW";
        };

        ipv4 = {
          method = "auto";
        };

        ipv6 = {
          addr-gen-mode = "default";
          method = "auto";
        };
      };

      profiles.UHOHOI = {
        connection = {
          id = "UHOHOI";
          type = "wifi";
        };

        wifi = {
          mode = "infrastructure";
          ssid = "UHOHOI";
        };

        wifi-security = {
          auth-alg = "open";
          key-mgmt = "wpa-psk";
          psk = "$UHOHOI_PSK";
        };

        ipv4 = {
          method = "auto";
        };

        ipv6 = {
          addr-gen-mode = "default";
          method = "auto";
        };
      };
    };
  };

  # bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable touchpad support (enabled by default in most desktopManager).
  services.libinput.enable = true;

  # Enable fingerprint.
  # Don't forget to run `sudo fprintd-enroll` and test with `sudo fprintd-verify`.
  # Bug: pam_fprintd.so should come before pam_unix.so.
  # https://github.com/NixOS/nixpkgs/issues/239770
  # https://github.com/NixOS/nixpkgs/blob/2becde3c1913fc74dec4108a067bfb5f5b93096b/nixos/modules/security/pam.nix#L663
  # ! Build failure as of 2025/03/29
  # services.fprintd = {
  # enable = true;
  # tod = {
  # enable = true;
  # driver = pkgs.libfprint-2-tod1-vfs0090;
  # };
  # };

  # environment.etc = {
  #   "default/locale".text = ''
  #     LANG="ja_JP.UTF-8"
  #   '';
  # };

  fonts = {
    packages = with pkgs; [
      # Default fonts
      dejavu_fonts
      freefont_ttf
      gyre-fonts # TrueType substitutes for standard PostScript fonts
      liberation_ttf
      unifont
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      # Additional fonts
      nerd-fonts.hack # for terminal
      nerd-fonts.intone-mono # for coding
    ];

    # Alphabets will be rendered with DejaVu and CJK will be rendered with Noto
    fontconfig.defaultFonts = {
      serif = [
        "DejaVu Serif"
        "Noto Serif CJK JP"
        "Noto Color Emoji"
      ];
      sansSerif = [
        "DejaVu Sans"
        "Noto Sans CJK JP"
        "Noto Color Emoji"
      ];
      monospace = [
        "Hack Nerd Font"
        "Noto Sans Mono CJK JP"
        "Noto Color Emoji"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
