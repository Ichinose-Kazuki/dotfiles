{
  host,
  lib,
  ...
}:

{
  imports = [
    ./vim
  ]
  ++ lib.optionals (host == "x1carbon") [
    ./vscode
  ];
}
