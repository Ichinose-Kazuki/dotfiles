{
  pkgs,
  lib,
  config,
  osConfig,
  inputs,
  ...
}:

# plasma-manager module: guarded on compositor == "plasma".
# The plasma-manager flake input provides the programs.plasma option.
# When compositor != "plasma" (e.g. x1carbon uses "niri"), we skip this
# entirely to preserve baseline EVAL_FAILED behaviour for programs.plasma.
#
# TODO Phase E+: conditionally import inputs.plasma-manager.homeManagerModules.plasma-manager
# and enable programs.plasma when compositor == "plasma" is selected.
{ }
