{
  pkgs,
  lib,
  inputs,
  config,
  osConfig,
  ...
}:

{
  imports = lib.optionals (builtins.elem "nvim" osConfig.myModule.home.editors) [
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
