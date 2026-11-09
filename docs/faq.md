# FAQ

## What is NoobWRT?

NoobWRT is a curated OpenWrt firmware build for the ZTE MF286D. It provides
predictable defaults, PassWall 1, modem tooling and a small, maintained package
set.

## How do I install this on a router that still has the ZTE firmware?

Two paths are documented in [Installation](installation.md):

- **UART + TFTP** (recommended) — serial console on the X8 header, boot an
  initramfs, remove the stock UBI volumes, then `sysupgrade -n`.
- **Without a serial cable** (community, unofficial) — rebuild `root_uImage` from
  the original ZTE file plus our `sysupgrade.bin` and flash it with ZTE's
  `ZTE_Sales_Update_Framework.exe`. Windows-only, region-specific, and limited by
  the stock kernel/rootfs size.

## Which firmware file should I download?

Use the `sysupgrade` image from a maintainer build:

`openwrt-ipq40xx-generic-zte_mf286d-squashfs-sysupgrade.bin`

See [Releases](builds.md).

## Is there a PassWall 2 build?

No. This repository ships only the **passwall1** variant.

## Why is the Wi-Fi country `IT`?

The device overlay mirrors the reference ZTE MF286D image, which was built for
Italy. Change the country in `Network` → `Wireless` before using the router
elsewhere.

## Why is there no phone (VoIP) support?

The MF286D has no working VoIP support in OpenWrt. This is an upstream hardware
limitation, not a NoobWRT choice.

## Can I use the Ethernet WAN instead of LTE?

Yes. `lan1` is the WAN port. Set `network.wan` to `proto dhcp` on device `lan1`, or
configure PPPoE there. The LTE modem then stays available as a second interface.

## Why is there no Xray core in the firmware?

The firmware partition is only 29 MiB and Xray is ~10.8 MiB compressed. The image
ships PassWall without a core; `/etc/init.d/passwall-core` downloads it into RAM
(`/tmp/xray`) after every boot. Internet is required once per boot. See
[Packages](packages.md#passwall-core-downloaded-into-ram-at-boot).

## Is it safe to flash this firmware?

Flashing firmware carries risk. Follow [Installation](installation.md) and ensure
stable power. Recovery is possible over UART/TFTP (see [Recovery](recovery.md)).

## Can I revert to stock firmware?

Only if you backed up the original partitions. This repository does not ship a
stock-restore image. See [Recovery](recovery.md#restoring-the-stock-firmware).

## How do I lock LTE bands?

The reference image used `luci-app-modemband`, which is not part of this build.
You can still query and set bands manually with the modem AT port:

```sh
# show current bands (example AT port)
gcom -d /dev/ttyUSB1
> AT+ZNLOCKBAND?
```

Install `luci-app-modemband` from a compatible feed if you want the LuCI page.

## How do I change the UI theme?

`System` → `System` → `Language and Style` → `Design`. Only the bootstrap theme is
installed by default.
