# Installation

This page covers both cases:

- **A router still on the official ZTE firmware** — you must get OpenWrt onto it first.
- **A router already running OpenWrt / NoobWRT** — a normal sysupgrade.

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

Use the OpenWrt release initramfs for the same version as the build you intend to
install, for example:

```text
openwrt-25.12.x-ipq40xx-generic-zte_mf286d-initramfs-fit-zImage.itb
```

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

## B. From stock ZTE firmware — without a serial cable (community method)

The community method flashes a modified **`root_uImage`** through ZTE's own update
tool. It avoids opening the case, but it depends on ZTE tooling and on your stock
firmware variant.

!!! warning "Unofficial and variant-dependent"
    This path is not maintained by OpenWrt or by this repository. The tool is
    Windows-only, the package is built for Nordic/Telia units, and the kernel and
    rootfs size limits (about 2.9 MB / 4 MB) come from the stock layout. A modern
    25.12 image is larger than those limits; the builder script warns and continues,
    but a kernel that is too large can leave the unit unbootable. Use path A if you
    can.

### How it works

1. ZTE's `ZTE_Sales_Update_Framework.exe` flashes a file named `root_uImage` from
   an `UPDATE/` folder.
2. You rebuild that `root_uImage` from the **original** one plus an OpenWrt
   `sysupgrade.bin` (kernel + rootfs), then let the ZTE tool write it.

### Steps

1. Obtain the community package (`zte mf286d Nordic to OPENWRT.7z.00*`, split
   archive) and extract it. It contains the ZTE update framework and the original
   `root_uImage` (exactly 38,797,312 bytes).
2. Get the NoobWRT `sysupgrade.bin` from a maintainer build.
3. Build the flashable image with
   [ZTE-MF286D-root_uImage-Builder](https://github.com/ilblogdicristiangallo/ZTE-MF286D-root_uImage-Builder):

```sh
# in a folder containing sysupgrade.bin and the original root_uImage
chmod +x build_root_uImage.sh
./build_root_uImage.sh
```

   The script extracts `kernel` and `root` from the sysupgrade tar, rebuilds a UBI
   image (`kernel`, `rootfs`, `rootfs_data`), inserts it at offset `0x800000` and
   writes `root_uImage.new` (38,797,312 bytes).

4. Rename `root_uImage.new` to `root_uImage` and put it in the `UPDATE/` folder of
   the ZTE package.
5. Run `ZTE_Sales_Update_Framework.exe` and follow the tool.
6. After the reboot you are in OpenWrt; install NoobWRT with `sysupgrade -n`, or
   flash the NoobWRT sysupgrade image directly if the tool accepted it.

A video walkthrough (Italian) exists:
[ZTE MF286D — installare OpenWrt senza porta seriale](https://www.youtube.com/watch?v=UjoAHUQ3qYE).

---

## C. From existing OpenWrt / NoobWRT — sysupgrade

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
5. If the LTE link is unstable, update the modem firmware to **B12** first. The
   MF286D community reports stability problems on older modem builds; the update is
   done from OpenWrt with `adb` plus AT commands on `/dev/ttyUSB1` (see
   [Modem Firmware](modem-firmware.md)).

If something goes wrong, follow [Recovery](recovery.md).
