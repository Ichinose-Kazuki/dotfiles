{
  services.tailscale = {
    enable = true;
    extraUpFlags = [
      "--ssh"
    ];
  };

  # Make tailscale state information persistent.
  # https://www.reddit.com/r/Tailscale/comments/11yu06x/where_does_linux_tailscale_save_settings_from_the/
  # Ignore warning: Neither /var/lib/nixos nor any of its parents are persisted.
  environment.persistence."/persistent" = {
    files = [
      "/var/lib/tailscale/tailscaled.state"
    ];
  };

  # TODO: Use routing features?
  # https://mynixos.com/nixpkgs/option/services.tailscale.useRoutingFeatures
}
