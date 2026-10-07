# Out-of-tree build of the Raspberry Pi kernel's macb driver.
#
# RP1 Ethernet on the Pi 5 does not come up with the mainline macb driver: the
# PHY never establishes a link even though it is powered, out of reset and
# driven by the right PHY driver. The Raspberry Pi kernel's macb carries
# vendor-specific bring-up (PHY reset through phy-reset-gpios plus its reset
# delays, and LPI handling) that the mainline driver lacks. This builds that
# driver against the mainline kernel so it can be used in its place.
#
# The mainline kernel has macb built in (CONFIG_MACB=y), so at load time it
# cannot be replaced by a module that claims the same driver name. This module
# therefore registers as "macb_rpi"; a systemd unit unbinds the built-in driver
# from the RP1 Ethernet device and binds this one instead.
{
  lib,
  stdenv,
  fetchurl,
  kernel,
}:

let
  vendorRev = "stable_20260724";
  vendorBase = "https://raw.githubusercontent.com/raspberrypi/linux/${vendorRev}/drivers/net/ethernet/cadence";

  macbMain = fetchurl {
    url = "${vendorBase}/macb_main.c";
    hash = "sha256-cPTnq4fuEiKS4PfEdOBNgo82tOnfPp6Cyw7H5ETSSdU=";
  };
  macbH = fetchurl {
    url = "${vendorBase}/macb.h";
    hash = "sha256-J3HV7dDd874x9wZvnMNzyLRwhecVUVx/Vg+z3XkYAMM=";
  };
  macbPtp = fetchurl {
    url = "${vendorBase}/macb_ptp.c";
    hash = "sha256-6GxjnDNQ1DbCW6owVFsC2bORb+PNuhpJC9T6sS68c/0=";
  };

  # sha256 of the mainline kernel's macb sources that this module is written to
  # replace. If a nixpkgs update changes them, the mainline driver's behaviour
  # may have moved, so the build stops instead of shipping a module built on
  # stale assumptions.
  mainlineMacbMainSha256 = "691c0da780fb21679ad0620e1f820ca12b1a80f09c6927ca1f4d3cfe47e1e057";
  mainlineMacbHSha256 = "8618288eef8cedbb36982d14d1502f19139fe047f82cbfcb7c68bed5ea67f73b";
in
stdenv.mkDerivation {
  pname = "macb-rpi";
  version = kernel.version;

  dontUnpack = true;

  nativeBuildInputs = kernel.moduleBuildDependencies;

  enableParallelBuilding = true;
  hardeningDisable = [ "pic" ];
  dontStrip = true;

  buildPhase = ''
    runHook preBuild

    mkdir -p mainline
    tar -xJf ${kernel.src} -C mainline \
      --wildcards '*/drivers/net/ethernet/cadence/macb_main.c' \
                   '*/drivers/net/ethernet/cadence/macb.h'
    gotMain=$(sha256sum "$(find mainline -name macb_main.c)" | cut -d' ' -f1)
    gotH=$(sha256sum "$(find mainline -name macb.h)" | cut -d' ' -f1)
    if [ "$gotMain" != "${mainlineMacbMainSha256}" ] || [ "$gotH" != "${mainlineMacbHSha256}" ]; then
      echo "ERROR: the mainline kernel's macb sources changed (nixpkgs update)." >&2
      echo "  macb_main.c expected ${mainlineMacbMainSha256}, got $gotMain" >&2
      echo "  macb.h      expected ${mainlineMacbHSha256}, got $gotH" >&2
      echo "Re-check that the Raspberry Pi macb still supersedes the mainline one." >&2
      exit 1
    fi

    cp ${macbMain} macb_main.c
    cp ${macbH} macb.h
    cp ${macbPtp} macb_ptp.c

    sed -i 's/\.name\(\s*\)= "macb"/.name\1= "macb_rpi"/' macb_main.c
    sed -i 's/platform:macb/platform:macb_rpi/' macb_main.c

    cat > Makefile <<'EOF'
    obj-m := macb_rpi.o
    macb_rpi-y := macb_main.o macb_ptp.o
    EOF

    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$PWD modules
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -D -m644 macb_rpi.ko "$out/lib/modules/${kernel.modDirVersion}/macb_rpi.ko"
    runHook postInstall
  '';

  meta = {
    description = "Raspberry Pi kernel's macb Ethernet driver, built out-of-tree against mainline";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
