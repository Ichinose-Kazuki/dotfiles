{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  programs.vim = {
    enable = true;
    extraConfig = ''
      set encoding=utf-8
      set fileencodings=utf-8,sjis,cp932,euc-jp
      set fileencoding=utf-8
    '';
  };
}
