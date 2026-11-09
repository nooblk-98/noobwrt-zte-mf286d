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

The ZTE bootloader will not take a sysupgrade image. It takes a **`root_uImage`**
file through ZTE's own updater, so the OpenWrt kernel and rootfs are wrapped into
that container first.

!!! warning "Unofficial and variant-dependent"
    The tool is Windows-only, the community package targets Nordic/Telia units, and
    the stock volume sizes are smaller than a 25.12 image. The builder script warns
    and continues; a kernel that is too large for the bootloader can leave the unit
    unbootable. Without a serial cable there is no recovery path — have the
    [UART guide](uart-guide.md) ready before you start.

### Connection: LAN cable, not Wi-Fi

The ZTE tool talks to the router over the wired management interface, so:

- Connect the PC to a **LAN port of the router with an Ethernet cable**.
- **Disable the PC's Wi-Fi adapter** before running the tool (Windows: Control Panel
  → Network and Internet → Network and Sharing Center → Change adapter settings →
  right-click Wi-Fi → Disable). Two active paths confuse the tool and the update
  server.
- Temporarily disable antivirus/firewall prompts while the tool runs.
- Leave the PC on DHCP; the tool finds the router itself.
- Do **not** use Wi-Fi for the flash itself — the radio goes down during the reboot
  and the update would stall.

!!! warning "Move the cable after the flash"
    On stock ZTE firmware all four ports are LAN. In OpenWrt **`lan1` becomes the
    WAN port**, and only `lan2`, `lan3`, `lan4` are LAN. After the router reboots,
    move the cable to `lan2`/`lan3`/`lan4` before opening `http://192.168.1.1`.

### Prerequisite: Nordic firmware

The community package is built for **Nordic/Telia** units. If your MF286D runs a
carrier firmware (TIM, H3G, etc.), install the Nordic firmware first — the OpenWrt
container is only accepted from that base. The Nordic images are on the same blog
that documents this method.

### What you need

1. A Windows PC with an Ethernet port.
2. The community package `zte mf286d Nordic to OPENWRT.7z.001 … .007` (~370 MB).
   It contains `ZTE_Sales_Update_Framework.exe` and the original `root_uImage`.
   Sources: [makebit/mf286d-openwrt](https://github.com/makebit/mf286d-openwrt)
   (`resources/`) or the Google Drive link in that README.
3. A `root_uImage` for the build you want — either the prebuilt one below, or build
   it yourself.

### Option 1 — use the prebuilt `root_uImage`

The maintainer build `mf286d-first-20261109-1142` ships one:

| | |
|---|---|
| File | `root_uImage` |
| Size | 38,797,312 bytes (exactly) |
| SHA-256 | `8c5695f26d298a4ed111e6c7d3be06bb06c7660fdc3411c5335dd096d5504461` |
| Location | private Drive → `zte-mf286d/install/mf286d-first-20261109-1142/root_uImage` |

1. Download `root_uImage` and check its size and SHA-256.
2. Open the ZTE package and replace the file in its `UPDATE/` folder with this one.
   The name must stay exactly `root_uImage` (no extension).
3. Run `ZTE_Sales_Update_Framework.exe` **as Administrator** and follow its prompts.
4. Do not power off. The router reboots into OpenWrt in about 3–5 minutes.

### Option 2 — build `root_uImage` yourself

Any Linux box or WSL works. You need the original `root_uImage` (38,797,312 bytes)
from the community package, plus the sysupgrade image from this build.

```sh
sudo apt install mtd-utils
# original container (from the builder repo's UPDATE folder)
wget https://raw.githubusercontent.com/ilblogdicristiangallo/ZTE-MF286D-root_uImage-Builder/main/UPDATE/root_uImage.zip
unzip root_uImage.zip                  # -> root_uImage, 38,797,312 bytes
stat -c%s root_uImage                  # must print 38797312

# unpack our sysupgrade image
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

Alternatively run the upstream helper in a folder that contains `sysupgrade.bin`
and `root_uImage`:

```sh
chmod +x build_root_uImage.sh && ./build_root_uImage.sh
```

### What ends up inside the container

| Volume | Content | Size |
|---|---|---|
| `kernel` | OpenWrt kernel (uncompressed) | 3.43 MiB (29 LEBs) |
| `rootfs` | squashfs with LuCI, PassWall, modem tools | 13.73 MiB (114 LEBs) |
| `rootfs_data` | overlay, `autoresize` | remainder (~10.5 MiB) |

The container is 38,797,312 bytes with the UBI area at offset `0x800000`. The
stock ZTE volumes were 23 LEBs (kernel) and 32 LEBs (rootfs); this build is
larger, which is the main risk of this method.

### After it boots

You are already running the built firmware (kernel + rootfs come from the
sysupgrade image). Continue with [After installation](#after-installation).

Later upgrades use the normal sysupgrade path — no ZTE tool needed.

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
