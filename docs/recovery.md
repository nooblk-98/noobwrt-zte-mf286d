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

## Returning to stock

Restoring ZTE stock firmware is not covered by this repository. Keep a full backup
of the original partitions (taken before the first flash) if you may need to go
back. The stock layout uses UBI volumes `ubi_rootfs` and `ubi_rootfs_data` on
MTD 9; they are removed during the OpenWrt first-time install.
