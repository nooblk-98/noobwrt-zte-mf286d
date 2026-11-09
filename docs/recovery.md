# Recovery

If something goes wrong during flashing or upgrades, try the options below in
order.

## Failsafe Mode

Failsafe starts the installed firmware with default network settings. It helps
when a bad setting locks you out, but not when the firmware itself does not boot.

1. Power off the device.
2. Press and hold the reset button.
3. Power on while holding reset for about 10 seconds.
4. Set your computer to a static IP such as `192.168.1.2`, then connect with SSH
   to `192.168.1.1` and fix the configuration or re-flash a valid sysupgrade image.

## UART / TFTP Recovery

If the router does not boot at all, use the serial console and U-Boot. This is the
same path used for first-time installation and is the most reliable way to recover
the MF286D.

1. Connect the X8 header at `115200 8N1` (see [UART Guide](uart-guide.md)).
2. Serve an `initramfs` image over TFTP.
3. In U-Boot:

```text
setenv serverip 192.168.1.3
setenv ipaddr 192.168.1.72
set fdt_high 0x85000000
tftp openwrt-ipq40xx-generic-zte_mf286d-initramfs-fit-zImage.itb
bootm $loadaddr
```

4. From the initramfs, flash the sysupgrade image or clean the UBI volumes as
   described in [Installation](installation.md).

!!! warning "Do not force an unsupported image"
    If `sysupgrade -T` reports that the device is not supported by the image, do
    not run `sysupgrade -F`. Use the UART/TFTP path instead.

## Restoring the stock firmware

There is no stock image in this repository. Restoring ZTE firmware needs a dump of
your own unit (taken before flashing) or a matching regional dump.

### From OpenWrt

With a full dump of the stock partitions:

```sh
mtd write mtd8.bin /dev/mtd8     # stock web UI
mtd write mtd9.bin /dev/mtd9     # stock rootfs
reboot
```

The stock layout uses UBI volumes `ubi_rootfs` and `ubi_rootfs_data` inside the
`rootfs` partition (MTD 9); the first-time OpenWrt install removes them.

### Restoring the MAC address

`mtd2` holds the MAC/calibration data. If it is lost or overwritten, Wi-Fi and
Ethernet get invalid addresses. The MAC is the last 3 bytes of the `mtd2` dump
with the ZTE OUI `D4:72:26`; the community has a
[helper script](https://github.com/ilblogdicristiangallo/ZTE-MF286D-Generate-Mac-Address)
that rebuilds a valid `mtd2.bin`, which is then written back with:

```sh
mtd write mtd2.bin /dev/mtd2
reboot
```

!!! danger "Back up `mtd2` first"
    There is no way to regenerate the factory calibration. Always keep a copy of
    your own `mtd2` before the first flash.

### Community stock dumps

Regional dumps and the "Nordic B12" package circulate in the community (for
example
[Downgrade-Dump-ZTE-MF286D-Nordic-B12](https://github.com/ilblogdicristiangallo/Downgrade-Dump-ZTE-MF286D-Nordic-B12)).
They are carrier/region specific. Writing another unit's `mtd2` clones its MAC —
do not do that on a network where both devices will be present.
