{ lib, pkgs, inputs, ... }:

let
  pkgs-latest = import inputs.nixpkgs { system = "aarch64-linux"; };
in
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
    package = pkgs-latest.tailscale;
  };

  # Linux optimizations for subnet routers and exit nodes
  # https://tailscale.com/kb/1320/performance-best-practices#linux-optimizations-for-subnet-routers-and-exit-nodes
  environment.systemPackages = with pkgs; [
    ethtool
    wirelesstools # Required by networkd-dispatcher for iwconfig (networkd-dispatcher is still not working, saying "No valid path found for iwconfig")
  ];
  # tx-udp-segmentation described in https://tailscale.com/blog/more-throughput is not supported by the Raspberry Pi 3B+.
  services.networkd-dispatcher = {
    enable = true;
    rules = {
      "50-tailscale" = {
        onState = [ "routable" ];
        script = ''
          #!${pkgs.runtimeShell}
          ${lib.getExe pkgs.ethtool} -K eth0 rx-udp-gro-forwarding on rx-gro-list off
        '';
      };
    };
  };

  # Make tailscale state information persistent.
  # https://www.reddit.com/r/Tailscale/comments/11yu06x/where_does_linux_tailscale_save_settings_from_the/
  # Ignore the warning: "Neither /var/lib/nixos nor any of its parents are persisted".
  # environment.persistence."/persistent" = {
  #   files = [
  #     "/var/lib/tailscale/tailscaled.state"
  #   ];
  # };
}
