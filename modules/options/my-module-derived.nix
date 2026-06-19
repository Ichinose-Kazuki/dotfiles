# Derived myModule values (Dendritic pattern, layer 2).
#
# Some settings are a *consequence* of higher-level selectors rather than an
# independent decision. We compute them here with `lib.mkDefault` so a host can
# still override them explicitly in its host.nix.
#
# Imported into both evals alongside my-module.nix. It only sets `config`
# (no option declarations), reading the selectors declared in my-module.nix.
{ config, lib, ... }:

let
  cfg = config.myModule;
in
{
  config.myModule = {
    hardware = {
      # Any graphical session wants audio.
      sound = lib.mkDefault (cfg.desktop.compositor != "none");
      # Laptops have a battery worth managing.
      battery = lib.mkDefault (cfg.machine == "laptop");
    };

    # Cockpit's options require a recent nixpkgs; the SBC hosts pin an older
    # one, so default it off there and on for full machines.
    cockpit = lib.mkDefault (cfg.machine != "sbc");

    # Lix (pkgs.lixPackageSets) likewise needs a recent nixpkgs.
    lix = lib.mkDefault (cfg.machine != "sbc");
  };
}
