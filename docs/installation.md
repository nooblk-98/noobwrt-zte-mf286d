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

## B. From stock ZTE firmware — no serial cable (community method)

Use this when you do not want to open the case or do not have a 3.3 V USB-serial
adapter. ZTE's own updater flashes a `root_uImage` container; every build of this
firmware ships one with its kernel and rootfs already wrapped inside.

!!! warning "Read this first"
    - Windows-only tool, built for **Nordic/Telia** units.
    - The stock volumes are smaller than a 25.12 image (kernel 3.43 MiB vs 2.9 MiB,
      rootfs 13.73 MiB vs 4 MiB). It works on the community images, but a kernel that
      is too large for the bootloader can leave the unit unbootable.
    - **No serial cable means no recovery.** Have the [UART guide](uart-guide.md) and a
      3.3 V adapter ready before you start.

### Before you start

| Need | Detail |
|---|---|
| Windows PC | with an Ethernet port |
| ZTE package | `zte mf286d Nordic to OPENWRT.7z.001 … .007` (~370 MB) from [makebit/mf286d-openwrt](https://github.com/makebit/mf286d-openwrt) `resources/` |
| Container | `install/root_uImage` from the build you want |
| Base firmware | **Nordic** — flash Nordic first if the unit runs TIM/H3G firmware |

### Step 1 — Prepare the PC

1. Connect an Ethernet cable: PC → any **LAN** port of the router.
2. **Disable Wi-Fi** on the PC (Control Panel → Network and Internet → Network and
   Sharing Center → Change adapter settings → right-click Wi-Fi → Disable).
3. Temporarily disable antivirus real-time scanning and firewall prompts.
4. Leave the PC on DHCP; the tool finds the router itself.

### Step 2 — Get the container

Every build publishes `install/root_uImage` next to the images:

```text
zte-mf286d/passwall1/<build-tag>/install/root_uImage
```

1. Download it from the private Drive folder.
2. Verify it before flashing:

```sh
stat -c%s root_uImage     # must print 38797312
sha256sum root_uImage     # must match install/root_uImage.sha256
```

### Step 3 — Stage the update

1. Extract the ZTE package.
2. Open its `UPDATE/` folder and **replace** `root_uImage` with the file from step 2.
   Keep the name exactly `root_uImage` (no extension).

### Step 4 — Flash

1. Run `ZTE_Sales_Update_Framework.exe` **as Administrator**.
2. Click **SW PATH** and select the extracted package folder.
3. Start the update and do not touch the router until it finishes.

### Step 5 — Wait for the reboot

The router comes back in about 3–5 minutes. Poll it from `cmd`:

```text
ping 192.168.1.1 -t
```

!!! warning "Move the cable before opening the UI"
    On stock firmware all four ports are LAN. In OpenWrt **`lan1` is the WAN port** —
    only `lan2`, `lan3`, `lan4` are LAN. Leave the cable in `lan1` and the web UI will
    look unreachable.

### Step 6 — First boot

Open `http://192.168.1.1` and:

1. set the root password,
2. set the Wi-Fi country and key,
3. set the APN at `http://192.168.1.1/apn.html` or in LuCI → `Network` → `Interfaces`.

You are already running the built firmware — the container holds this build's kernel
and rootfs. Later upgrades use the normal [sysupgrade](#c-from-existing-openwrt-noobwrt-sysupgrade)
path, no ZTE tool needed.

### Build the container manually

If you want to wrap a different sysupgrade image, any Linux box or WSL works:

```sh
sudo apt install mtd-utils
wget https://raw.githubusercontent.com/ilblogdicristiangallo/ZTE-MF286D-root_uImage-Builder/main/UPDATE/root_uImage.zip
unzip root_uImage.zip                  # -> root_uImage, 38,797,312 bytes
stat -c%s root_uImage                  # must print 38797312

tar xf openwrt-ipq40xx-generic-zte_mf286d-squashfs-sysupgrade.bin
mv sysupgrade-zte_mf286d/kernel kernel-new.bin
mv sysupgrade-zte_mf286d/root   rootfs-new.squashfs

cat > ubinize.cfg <<'EOF'
[kernel]
mode=ubi
image=kernel-new.bin
vol_id=0
vol_type=dynamic
vol_name=kernel
vol_alignment=1

[rootfs]
mode=ubi
image=rootfs-new.squashfs
vol_id=1
vol_type=dynamic
vol_name=rootfs
vol_alignment=1

[rootfs_data]
mode=ubi
vol_id=2
vol_type=dynamic
vol_name=rootfs_data
vol_flags=autoresize
vol_alignment=1
vol_size=1MiB
EOF

ubinize -o ubi-new.img -p 131072 -m 2048 -O 2048 ubinize.cfg
truncate -s 30408704 ubi-new.img        # 29 MiB UBI area
cp root_uImage root_uImage.new
dd if=ubi-new.img of=root_uImage.new bs=1M seek=8 conv=notrunc
mv root_uImage.new root_uImage
stat -c%s root_uImage                   # must print 38797312
```

### If it does not come back

1. Power-cycle once and wait five minutes — the first boot writes the overlay.
2. Still nothing: use [UART/TFTP recovery](recovery.md#uart-tftp-recovery). Do not
   re-run the ZTE tool against the same unit.

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
5. **PassWall core:** on first boot the router downloads the Xray core into RAM
   (`/tmp/xray`). It needs working WAN for about a minute; check
   `logread -e passwall-core`. See [Packages](packages.md#passwall-core-downloaded-into-ram-at-boot).
6. If the LTE link is unstable, update the modem firmware to **B12** first. The
   MF286D community reports stability problems on older modem builds; the update is
   done from OpenWrt with `adb` plus AT commands on `/dev/ttyUSB1` (see
   [Modem Firmware](modem-firmware.md)).

If something goes wrong, follow [Recovery](recovery.md).
