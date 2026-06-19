{ lib, options, ... }:

{
  # Force disable xdg autostart since it conflicts with systemd daemons.
  # `xdg.autostart` was added in a newer home-manager release; use optionalAttrs
  # (not mkIf) so the attribute is ABSENT in old HM, avoiding "option does not
  # exist" even when the guard condition is false.
  config = lib.optionalAttrs (lib.hasAttrByPath [ "xdg" "autostart" "enable" ] options) {
    xdg.autostart.enable = lib.mkForce false;
  };
}
