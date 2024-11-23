{ config
, lib
, pkgs
, inputs
, ...
}:

{
  wsl.wslConf.network.hostname = "wsl2";
}
