# Installation

This page covers both cases:

- **A router still on the official ZTE firmware** — you must get OpenWrt onto it first.
- **A router already running OpenWrt / NoobWRT** — a normal sysupgrade.

!!! info "Official reference"
    These instructions follow the upstream OpenWrt device page:
    **[openwrt.org/toh/zte/mf286d](https://openwrt.org/toh/zte/mf286d)**. If anything
    here disagrees with the wiki, the wiki is authoritative.

!!! note "Before you flash"
    - Back up the original partitions if you may ever want to return to stock.
      At minimum: `mtd2` (MAC/ART), `mtd8` (`web`), `mtd9` (`rootfs`).
    - Use a stable power supply. The MF286D has no battery backup.
    - Keep the SIM out until the router boots OpenWrt for the first time.

## Flash layout (for backups)

```text
"nand":
0x000000000000-0x0000000a0000 : "fota-flag"
0x0000000a0000-0x000000120000 : "ART"
0x000000120000-0x0000001a0000 : "mac"
0x0000001a0000-0x000000260000 : "reserved2"
0x000000260000-0x000000660000 : "cfg-param"
0x000000660000-0x000000a60000 : "log"
0x000000a60000-0x000000b00000 : "oops"
0x000000b00000-0x000001000000 : "reserved3"
0x000001000000-0x000001800000 : "web"
0x000001800000-0x000003500000 : "rootfs"
0x000003500000-0x000004e00000 : "data"
0x000004e00000-0x000008000000 : "fota"
```

Back up from a root shell (stock or OpenWrt):

```sh
cat /proc/mtd
dd if=/dev/mtd2 of=/tmp/mtd2.bin     # MAC / calibration
dd if=/dev/mtd8 of=/tmp/mtd8.bin     # stock web UI
dd if=/dev/mtd9 of=/tmp/mtd9.bin     # stock rootfs
```

Copy them off the device. `mtd2` is the only copy of your MAC address.

---

## A. From stock ZTE firmware — UART + TFTP (recommended)

This is the upstream OpenWrt procedure. It is the most reliable path and the one
the device support commit documents.

You need: a 3.3 V USB-to-serial adapter, a TFTP server, and an **initramfs** image
for `ipq40xx/generic` `zte_mf286d`.

### 1. Get an initramfs image

Every NoobWRT build publishes one next to the sysupgrade image:

```text
openwrt-ipq40xx-generic-zte_mf286d-initramfs-zImage.itb
```

This is the same image the wiki lists as *Firmware OpenWrt Install*. If you only have
an older release, use the matching file from
[downloads.openwrt.org](https://downloads.openwrt.org/releases/) for
`ipq40xx/generic`.

Place it in the root of your TFTP server. This example uses `192.168.1.3` for the
server and `192.168.1.72` for the router.

### 2. Connect serial

X8 header, `115200 8N1` — see the [UART Guide](uart-guide.md).

### 3. Boot the initramfs from U-Boot

Connect the TFTP server to a LAN port, power on, and interrupt autoboot:

```text
setenv serverip 192.168.1.3
setenv ipaddr 192.168.1.72
set fdt_high 0x85000000
tftp openwrt-ipq40xx-generic-zte_mf286d-initramfs-fit-zImage.itb
bootm $loadaddr
```

### 4. Remove the stock UBI volumes

Log in over SSH or serial (the initramfs runs from RAM):

```sh
ubiattach -m 9
ubirmvol /dev/ubi0 -N ubi_rootfs
ubirmvol /dev/ubi0 -N ubi_rootfs_data
```

`ubiattach` may report an error if UBI was already attached; that is harmless.
`ubirmvol` may fail on `ubi_rootfs_data` if the stock firmware did not create it.

### 5. Install the NoobWRT image

```sh
sysupgrade -n /tmp/openwrt-ipq40xx-generic-zte_mf286d-squashfs-sysupgrade.bin
```

An `ubi attach` error during the flash can be ignored while the process continues.

---

## B. From existing OpenWrt / NoobWRT — sysupgrade

Use `openwrt-ipq40xx-generic-zte_mf286d-squashfs-sysupgrade.bin`.

### Web UI

1. Log in at `http://192.168.1.1`.
2. Go to `System` then `Backup / Flash Firmware`.
3. Upload the image.
4. Untick `Keep settings` if you are coming from a different firmware.
5. Confirm and wait for the reboot.

### CLI

```sh
scp openwrt-ipq40xx-generic-zte_mf286d-squashfs-sysupgrade.bin root@192.168.1.1:/tmp/
sysupgrade -T /tmp/openwrt-ipq40xx-generic-zte_mf286d-squashfs-sysupgrade.bin
sysupgrade -n /tmp/openwrt-ipq40xx-generic-zte_mf286d-squashfs-sysupgrade.bin
```

!!! danger "`-n` erases all settings"
    `sysupgrade -n` erases all settings, including PassWall nodes and Wi-Fi. Drop
    `-n` to keep your settings.

If `sysupgrade -T` reports that the device is not supported, do **not** force the
flash. Use path A instead.

---

## After installation

1. Open `http://192.168.1.1` (LAN ports `lan2`–`lan4`, or the Wi-Fi AP).
2. Set the root password immediately — the shipped config has none.
3. Set the correct Wi-Fi country and key. The reference defaults use country `IT`
   and open Wi-Fi.
4. Configure the APN: `http://192.168.1.1/apn.html`, or LuCI →
   `Network` → `Interfaces` → `wan`. Defaults are QMI on `/dev/cdc-wdm0`, APN
   `internet`, IPv4.
5. **PassWall core:** on first boot the router downloads the Xray core into RAM
   (`/tmp/xray`). It needs working WAN for about a minute; check
   `logread -e passwall-core`. See [Packages](packages.md#passwall-core-downloaded-into-ram-at-boot).
6. If the LTE link is unstable, update the modem firmware to **B12** first. The
   MF286D community reports stability problems on older modem builds; the update is
   done from OpenWrt with `adb` plus AT commands on `/dev/ttyUSB1` (see
   [Modem Firmware](modem-firmware.md)).

If something goes wrong, follow [Recovery](recovery.md).
