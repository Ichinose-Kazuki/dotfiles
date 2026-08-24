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
    inputs.nvim-config.homeModules.default
  ];

  myNvim = {
    enable = true;
    fileExplorer = "oil"; # "oil" または "neo-tree"
    lsp.servers = [
      "lua_ls"
      "nil_ls"
      "pyright"
      "clangd"
    ];
  };

  programs.zsh.shellAliases.n = "nvim";
}
