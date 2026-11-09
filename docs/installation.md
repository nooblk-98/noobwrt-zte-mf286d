# Installation

!!! note "Before You Flash"
    - Back up your current configuration (`System` then `Backup / Flash Firmware`).
    - Ensure stable power to avoid bricking.
    - The MF286D has **no** official web-flash path from stock firmware. First-time
      installation needs serial console + TFTP.

## Upgrading an existing OpenWrt / NoobWRT installation

Use the sysupgrade image from a maintainer build:
`openwrt-ipq40xx-generic-zte_mf286d-squashfs-sysupgrade.bin`.

### Web UI

1. Log in at `http://192.168.1.1`.
2. Go to `System` then `Backup / Flash Firmware`.
3. Upload the sysupgrade image.
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
flash. Follow the first-time procedure below.

## First-time installation from stock firmware

This procedure comes from the upstream OpenWrt MF286D support commit. It wipes the
stock ZTE partition layout, so back up anything you need first.

1. Put an OpenWrt/NoobWRT `initramfs` image for `ipq40xx/generic` `zte_mf286d` on
   a TFTP server (for example `openwrt-ipq40xx-generic-zte_mf286d-initramfs-fit-zImage.itb`,
   served from `192.168.1.3`).
2. Connect the serial console to the **X8** header at `115200 8N1` (see
   [UART Guide](uart-guide.md)).
3. Connect the TFTP server to a LAN port.
4. Stop in U-Boot and run:

```text
setenv serverip 192.168.1.3
setenv ipaddr 192.168.1.72
set fdt_high 0x85000000
tftp openwrt-ipq40xx-generic-zte_mf286d-initramfs-fit-zImage.itb
bootm $loadaddr
```

5. Back up the original partitions if you may want to return to stock.
6. Log in over SSH or serial and remove the stock volumes:

```sh
ubiattach -m 9
ubirmvol /dev/ubi0 -N ubi_rootfs
ubirmvol /dev/ubi0 -N ubi_rootfs_data
```

7. Install the sysupgrade image:

```sh
sysupgrade -n /path/to/openwrt-ipq40xx-generic-zte_mf286d-squashfs-sysupgrade.bin
```

## After Upgrade

- Reconnect at `http://192.168.1.1`.
- Set the admin password.
- Set the correct Wi-Fi country and SSID (the reference defaults use `IT`).
- Configure the APN at `http://192.168.1.1/apn.html` or in LuCI → Network → Interfaces → WAN.

If something goes wrong, follow [Recovery](recovery.md).
