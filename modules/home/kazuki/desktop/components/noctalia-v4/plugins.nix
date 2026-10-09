{
  pkgs,
  lib,
  config,
  osConfig,
  inputs,
  ...
}:

{
  programs.noctalia-shell = {
    plugins =
      let
        url = "https://github.com/noctalia-dev/noctalia-plugins";
      in
      {
        sources = [
          {
            enabled = true;
            name = "Official Noctalia Plugins";
            inherit url;
          }
        ];
        states = {
          privacy-indicator = {
            enabled = true;
            sourceUrl = url;
          };
          screen-recorder = {
            enabled = true;
            sourceUrl = url;
          };
          timer = {
            enabled = true;
            sourceUrl = url;
          };
          fancy-audiovisualizer = {
            enabled = true;
            sourceUrl = url;
          };
          polkit-agent = {
            enabled = true;
            sourceUrl = url;
          };
          kaomoji-provider = {
            enabled = true;
            sourceUrl = url;
          };
          screen-toolkit = {
            enabled = true;
            sourceUrl = url;
          };
          usb-drive-manager = {
            enabled = true;
            sourceUrl = url;
          };
          battery-monitor-plus = {
            enabled = true;
            sourceUrl = url;
          };
          kde-connect = {
            enabled = true;
            sourceUrl = url;
          };
          tailscale = {
            enabled = true;
            sourceUrl = url;
          };
          file-search = {
            enabled = true;
            sourceUrl = url;
          };
        };
        version = 2;
      };

    pluginSettings = {
      privacy-indicator = {
        hideInactive = true;
      };
      screen-recorder = {
        hideInactive = true;
      };
      usb-drive-manager = {
        autoMount = true;
        fileBrowser = "nemo";
        terminalCommand = "kitty";
      };
      tailscale = {
        hideDisconnected = true;
      };
      file-search = {
        showHidden = true;
      };
    };
  };

  # Dependencies
  ## Screen Recorder
  ### gpu-screen-recorder need to be enabled in nixos settings.
  ## Screen Toolkit
  home.packages =
    with pkgs;
    [
      grim
      slurp
      wl-clipboard
      # tesseract # Conflicts with one in flameshot ocr config.
      imagemagick
      zbar
      curl
      ffmpeg
      jq
      wl-screenrec
      translate-shell
      gifski
    ]
    ## USB Drive Manager
    ++ [
      udisks
      wl-clipboard
    ]
    ## KDE Connect
    ++ [
      sshfs
    ];
  services.kdeconnect.enable = true;
  ## File Search
  programs.fd.enable = true;
}
