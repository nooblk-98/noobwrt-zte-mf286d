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

Source: upstream OpenWrt support commit for `zte_mf286d`
(`a91ab8bc05b737d7e14976aaf929a71ea37fa1c6`).

## Network layout

OpenWrt maps the ports as follows:

- `lan1` → `wan` (Ethernet WAN)
- `lan2`, `lan3`, `lan4` → `br-lan` (`192.168.1.1/24`)
- `wan6` → DHCPv6 on `wan`
- LTE → `wan` as QMI on `/dev/cdc-wdm0` in the shipped config

## Known hardware limits

- Many LEDs are driven by the modem firmware, not the CPU. Only internal and Wi-Fi
  LEDs are controllable from OpenWrt.
- The Wi-Fi LED follows `phy0tpt` only.
- **No VoIP support.** The MF286D has no working phone port in OpenWrt.
- ZTE provides a single MAC address per device; OpenWrt derives WAN/WLAN MACs with +1/+2/+3 increments.

## Default Settings

Default Wi-Fi names, admin login and LAN IP are listed in
[Getting Started](getting-started.md#default-access).
