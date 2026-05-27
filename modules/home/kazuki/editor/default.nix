{
  host,
  lib,
  ...
}:

{
  imports = [
    ./nvim
    ./vim
  ]
  ++ lib.optionals (host == "x1carbon") [
    ./antigravity
    ./vscode
  ];
}
