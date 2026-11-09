# Hardware

## Specifications

| Component | Detail |
|---|---|
| SoC | Qualcomm IPQ4019 (ARM Cortex-A7, 4 cores) |
| RAM | 256 MB |
| Flash | 128 MB NAND + 2 MB NOR |
| WLAN 2.4 GHz | QCA4019, 802.11b/g/n, 2x2:2 |
| WLAN 5 GHz | QCA4019, 802.11a/n/ac, 2x2:2 |
| LTE | mPCIe Cat 12 modem (MDM9250), QMI |
| Ethernet | 4x Gigabit (`lan1` is the WAN port by default) |
| USB | 1x USB 2.0 external, 1x USB 3.0 internal (modem) |
| Serial console | X8 header, 115200 8N1 |

Sources: the [OpenWrt device page](https://openwrt.org/toh/zte/mf286d) and the
upstream support commit for `zte_mf286d` (`a91ab8bc05b737d7e14976aaf929a71ea37fa1c6`).

## Network layout

OpenWrt maps the ports as follows:

- `lan1` → `wan` (Ethernet WAN)
- `lan2`, `lan3`, `lan4` → `br-lan` (`192.168.1.1/24`)
- `wan6` → DHCPv6 on `wan`
- LTE → `wan` as QMI on `/dev/cdc-wdm0` in the shipped config

## Flash and image size budget

| Region | Size | Used by |
|---|---|---|
| NAND total | 128 MiB | whole device |
| SPI NOR | 2 MiB | bootloader (`SBL1`, `MIBIB`, `QSEE`, `APPSBL`) |
| `rootfs` (mtd9) | **29.00 MiB** (30,408,704 B) | kernel + OpenWrt rootfs + overlay |
| `data` (mtd10) | 25 MiB | stock data; unused by OpenWrt |
| `fota` (mtd11) | 50 MiB | stock FOTA; unused by OpenWrt |

The `rootfs` partition is a UBI volume: 232 PEBs of 128 KiB, 2 reserved, so
**230 LEBs × 126,976 B = 27.85 MiB** of usable space. The kernel is stored
uncompressed (≈3.3 MiB in the reference image), which leaves:

| Overlay wanted | Max rootfs (squashfs) |
|---|---|
| 0 MiB | 24.57 MiB |
| 2 MiB | 22.57 MiB |
| 4 MiB | 20.57 MiB |
| 6 MiB | 18.57 MiB |
| 8 MiB | 16.57 MiB |

Practical target for this build: **rootfs ≤ 20 MiB**, leaving ~4 MiB of overlay
for settings. The release hook fails the build above 27.85 MB of image payload and
warns above 25.5 MB.

For reference, the packages that will not fit: `sing-box` alone is 15.3 MiB and
`xray-core` is 10.8 MiB compressed. That is why the PassWall core is **not in the
image** — it is downloaded into RAM at boot (about 25 MB of tmpfs).

## Known hardware limits

- Many LEDs are driven by the modem firmware, not the CPU. Only internal and Wi-Fi
  LEDs are controllable from OpenWrt.
- The Wi-Fi LED follows `phy0tpt` only.
- **No VoIP support.** The MF286D has no working phone port in OpenWrt.
- ZTE provides a single MAC address per device; OpenWrt derives WAN/WLAN MACs with +1/+2/+3 increments.

## Default Settings

Default Wi-Fi names, admin login and LAN IP are listed in
[Getting Started](getting-started.md#default-access).
