{
  pkgs,
  lib,
  inputs,
  config,
  osConfig,
  ...
}:

{
  # Imported unconditionally so the `myNvim` option is always declared (needed
  # under whole-tree import, where every host reads this module). Activation is
  # still gated by the mkIf below.
  imports = [
    inputs.nvim-config.homeManagerModules.default
  ];

  config = lib.mkIf (builtins.elem "nvim" osConfig.myModule.home.editors) {
    myNvim = {
      enable = true;
      fileExplorer = "oil"; # "oil" または "neo-tree"
      lsp.servers = [
        "lua_ls"
        "nixd"
        "pyright"
        "clangd"
      ];
    };
  };
}
