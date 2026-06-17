{ config, lib, ... }:

{
  config = lib.mkIf config.myModule.hardware.sound {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    security.rtkit.enable = true;
  };
}
