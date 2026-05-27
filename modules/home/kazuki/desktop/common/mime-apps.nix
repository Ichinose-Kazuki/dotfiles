{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

let
  browsers = [
    "google-chrome.desktop"
    "firefox.desktop"
  ];
  fileManagers = [ ];
  pdfReaders = [ ];
  imageViewers = [ ];
  textEditors = [ "nvim.desktop" ];
in
{
  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      # Web
      "text/html" = browsers;
      "x-scheme-handler/http" = browsers;
      "x-scheme-handler/https" = browsers;
      "x-scheme-handler/about" = browsers;
      "x-scheme-handler/unknown" = browsers;

      # File Manager
      "inode/directory" = fileManagers;

      # PDF
      "application/pdf" = pdfReaders;

      # Images
      "image/jpeg" = imageViewers;
      "image/png" = imageViewers;
      "image/svg+xml" = imageViewers;
      "image/webp" = imageViewers;

      # Text
      "text/plain" = textEditors;
      "text/markdown" = textEditors;
      "application/json" = textEditors;
    };
  };

  xdg.desktopEntries.nvim = {
    name = "Neovim";
    genericName = "Text Editor";
    exec = "nvim %F";
    terminal = true; # Open in terminal
    categories = [
      "Utility"
      "TextEditor"
    ];
    mimeType = [ "text/plain" ];
  };
}
