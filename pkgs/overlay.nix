final: prev: {
  julia-mono-no-small = prev.callPackage ./julia-mono-no-small { };

  noto-fonts-cjk-sans-mono-no-wider-than-intone-mono =
    prev.callPackage ./noto-fonts-cjk-sans-mono-no-wider-than-intone-mono { };
}
