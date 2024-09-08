{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    openFirewall = true;
    extraUpFlags = [
      "--ssh"
      "--advertise-routes=192.168.11.0/24"
      "--advertise-exit-node"
    ];
  };

  # Make tailscale state information persistent.
  # https://www.reddit.com/r/Tailscale/comments/11yu06x/where_does_linux_tailscale_save_settings_from_the/
  # Ignore the warning: "Neither /var/lib/nixos nor any of its parents are persisted".
  environment.persistence."/persistent" = {
    files = [
      "/var/lib/tailscale/tailscaled.state"
    ];
  };
}
