{
  pkgs,
  lib,
  inputs,
  config,
  osConfig,
  ...
}:

{
  imports = [
    inputs.nvim-config.homeManagerModules.default
  ];

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
}
