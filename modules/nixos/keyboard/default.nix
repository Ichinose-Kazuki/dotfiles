{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  config = lib.mkIf (config.myModule.hostName == "x1carbon") {
    services.udev.extraRules = ''
      # Disable USB keyboard autosuspend to eliminate the lag (keyboard initialization) before password input after waking from system suspend.
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0853", ATTR{idProduct}=="0303", ATTR{power/control}="on"
    '';
    # 今あるラグはモニタ経由の接続によるもの。キーボードを直接繋げばラグ 0 になる。
  };
}
