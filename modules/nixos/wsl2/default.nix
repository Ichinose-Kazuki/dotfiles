{ ... }:

{
  # Children (graphics, networking, interop) and ../common/tailscale are
  # auto-imported by import-tree; tailscale is guarded by myModule.tailscale.
  options.virtualization.docker = {
    enable = true;
  };
}
