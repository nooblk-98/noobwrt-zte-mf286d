# UART Guide

Serial console on the ZTE MF286D. You need it for the first OpenWrt install and for
recovery when the router does not boot.

!!! info "Official reference"
    This page follows the **Serial** and **Opening the case** sections of
    [openwrt.org/toh/zte/mf286d](https://openwrt.org/toh/zte/mf286d). Photos are from
    that page (CC BY-SA). If anything here disagrees with the wiki, the wiki wins.

## What you need

| Item | Detail |
|---|---|
| Adapter | USB-to-serial, **3.3 V** (CP2102, FT232RL, CH340 set to 3.3 V) |
| Wires | 3 dupont leads (TX, RX, GND) — VCC is not used |
| Console | `picocom`, `minicom`, PuTTY or `screen` |
| TFTP server | for the initramfs image (install path) |
| Tools | PH1/PH2 screwdriver, plastic pry tool |

!!! warning
    Use a **3.3 V** adapter. A 5 V TTL adapter can damage the SoC. Never connect the
    VCC pin — the router is powered from its own supply.

## Opening the case

From the official page (skip steps 1–2 on units without a battery lid):

1. Take off the battery lid. The battery cage is a dummy — this model has no battery.
2. Unscrew the screw behind the battery lid.
3. Take off the back cover; it is held by plastic clamps.
4. Unscrew the four screws hidden behind the back case.
5. Remove the front panel from the blue chassis (more plastic clamps).
6. Unscrew the two screws securing the PCB.
7. Lift the board out of the blue chassis.

Work on an anti-static surface. More photos:
[case opened](https://openwrt.org/_media/media/zte/mf286d/mf286d-8.jpg),
[main PCB](https://openwrt.org/_media/media/zte/mf286d/mf286d-10.jpg),
[PCB details](https://openwrt.org/_media/media/zte/mf286d/mf286d-12.jpg).

## Connector: X8

`X8` is a 4-pin header on the left edge of the main PCB, next to the blue chassis
edge and roughly level with the middle of the board.

![X8 UART header with pin labels](images/mf286d-serial-console.jpg)

Pin order, from the pin closest to the `X8` silkscreen label to the farthest:

| Pin | Signal | Note |
|---|---|---|
| 1 | VCC (3.3 V) | **do not connect** |
| 2 | TX | → adapter RXD |
| 3 | RX | → adapter TXD |
| 4 | GND | → adapter GND |

Board overview — `X8` at the left edge:

![MF286D main PCB with X8 at the left edge](images/mf286d-main-pcb.jpg)

!!! note "Wire colours"
    The photo shows red = VCC, orange = TX, yellow = RX, green = GND. That is just how
    the wiki author wired it — follow the **pin order**, not the colours.

## Serial settings

```text
115200 baud, 8 data bits, no parity, 1 stop bit (8N1)
```

```sh
picocom -b 115200 /dev/ttyUSB0
```

If you see nothing, swap TX and RX.

## Access U-Boot

1. Open the serial terminal.
2. Power on the router.
3. Press **ESC** repeatedly to stop autoboot.

You should land on the U-Boot prompt. From there you can load an initramfs image:

```text
setenv serverip 192.168.1.3
setenv ipaddr 192.168.1.72
set fdt_high 0x85000000
tftp openwrt-ipq40xx-generic-zte_mf286d-initramfs-fit-zImage.itb
bootm $loadaddr
```

Connect the TFTP host to `lan2`, `lan3` or `lan4` — **not** the shared WAN/LAN1 port.

## After the initramfs boots

The initramfs runs from RAM. Continue with
[Installation → A. From stock ZTE firmware](installation.md#a-from-stock-zte-firmware-uart-tftp-recommended):

1. back up the partitions you may want later (`mtd2`, `mtd8`, `mtd9`),
2. remove the stock volumes with `ubiattach` / `ubirmvol`,
3. `sysupgrade -n` the image.

!!! tip "One step, not two"
    You do **not** have to install official OpenWrt first. NoobWRT is built for the
    same `ipq40xx/generic` `zte_mf286d` profile with the same partition layout, so
    `sysupgrade -n openwrt-ipq40xx-generic-zte_mf286d-squashfs-sysupgrade.bin` can
    flash the NoobWRT image directly from the initramfs.

    If you prefer, flash the official OpenWrt sysupgrade image first, boot it once,
    then sysupgrade to NoobWRT — that works too, it just takes an extra reboot.
