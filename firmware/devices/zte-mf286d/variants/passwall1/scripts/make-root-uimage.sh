#!/bin/sh
# Build a ZTE flashable root_uImage from the sysupgrade image produced by this
# build, so a stock-firmware router can be flashed with ZTE_Sales_Update_Framework
# (no serial cable).
#
# Output: $RUN_OUTPUT/install/root_uImage  (38,797,312 bytes, UBI at 0x800000)
#
# Needs the original ZTE container (root_uImage, 38,797,312 bytes). It is
# downloaded from the community builder repository and verified by SHA-256;
# nothing is vendored in this repository.

set -eu

: "${RUN_OUTPUT:?RUN_OUTPUT must be set by the builder}"
: "${BUILD_DIR:?BUILD_DIR must be set by the builder}"

CONTAINER_URL="https://raw.githubusercontent.com/ilblogdicristiangallo/ZTE-MF286D-root_uImage-Builder/main/UPDATE/root_uImage.zip"
CONTAINER_ZIP_SHA256="5d9fd84edd612b993e31015ea2433b7cd8bcec1726640859e7f20e74a4e101b6"
CONTAINER_SIZE=38797312
UBI_OFFSET=8388608
UBI_AREA=30408704
PEB=131072
MIN_IO=2048
VID_HDR=2048

log() { echo "root_uimage: $*"; }

SYSIMG=$(find "$RUN_OUTPUT" -maxdepth 1 -name '*sysupgrade*.bin' -print -quit 2>/dev/null || true)
if [ -z "$SYSIMG" ]; then
	log "no sysupgrade image in $RUN_OUTPUT; skipping container"
	exit 0
fi

UBINIZE=$(command -v ubinize 2>/dev/null || true)
if [ -z "$UBINIZE" ] && [ -x "$BUILD_DIR/staging_dir/host/bin/ubinize" ]; then
	UBINIZE="$BUILD_DIR/staging_dir/host/bin/ubinize"
fi
if [ -z "$UBINIZE" ]; then
	log "ubinize not found (PATH or staging_dir/host/bin); skipping container"
	exit 0
fi

WORK=$(mktemp -d "${TMPDIR:-/tmp}/root-uimage.XXXXXX")
trap 'rm -rf "$WORK"' EXIT INT TERM

log "downloading original ZTE container"
if ! wget -q -O "$WORK/root_uImage.zip" "$CONTAINER_URL"; then
	log "download failed; skipping container (firmware images are unaffected)"
	exit 0
fi
echo "$CONTAINER_ZIP_SHA256  $WORK/root_uImage.zip" | sha256sum -c - >/dev/null || {
	log "container archive checksum mismatch; skipping container"
	exit 0
}
unzip -o -q "$WORK/root_uImage.zip" -d "$WORK" || {
	log "cannot unpack container archive; skipping container"
	exit 0
}
SIZE=$(stat -c%s "$WORK/root_uImage")
if [ "$SIZE" -ne "$CONTAINER_SIZE" ]; then
	log "unexpected container size $SIZE; skipping container"
	exit 0
fi

mkdir -p "$WORK/sysupgrade"
tar xf "$SYSIMG" -C "$WORK/sysupgrade"
DIR=$(find "$WORK/sysupgrade" -maxdepth 1 -mindepth 1 -type d -print -quit)
if [ -z "$DIR" ] || [ ! -f "$DIR/kernel" ] || [ ! -f "$DIR/root" ]; then
	log "sysupgrade image is not a kernel+root tar; skipping container"
	exit 0
fi
cp "$DIR/kernel" "$WORK/kernel.bin"
cp "$DIR/root" "$WORK/rootfs.squashfs"

cat > "$WORK/ubinize.cfg" <<EOF
[kernel]
mode=ubi
image=$WORK/kernel.bin
vol_id=0
vol_type=dynamic
vol_name=kernel
vol_alignment=1

[rootfs]
mode=ubi
image=$WORK/rootfs.squashfs
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

"$UBINIZE" -o "$WORK/ubi.img" -p "$PEB" -m "$MIN_IO" -O "$VID_HDR" "$WORK/ubinize.cfg" 2>"$WORK/ubinize.log" || {
	log "ubinize failed; skipping container"
	cat "$WORK/ubinize.log"
	exit 0
}
UBI_SIZE=$(stat -c%s "$WORK/ubi.img")
if [ "$UBI_SIZE" -gt "$UBI_AREA" ]; then
	log "UBI payload $UBI_SIZE exceeds the 29 MiB area; skipping container"
	exit 0
fi
truncate -s "$UBI_AREA" "$WORK/ubi.img"

cp "$WORK/root_uImage" "$WORK/root_uImage.new"
dd if="$WORK/ubi.img" of="$WORK/root_uImage.new" bs=1M seek=$((UBI_OFFSET / 1048576)) conv=notrunc status=none
FINAL=$(stat -c%s "$WORK/root_uImage.new")
if [ "$FINAL" -ne "$CONTAINER_SIZE" ]; then
	log "container size $FINAL is wrong; skipping"
	exit 0
fi

mkdir -p "$RUN_OUTPUT/install"
cp "$WORK/root_uImage.new" "$RUN_OUTPUT/install/root_uImage"
( cd "$RUN_OUTPUT/install" && sha256sum root_uImage > root_uImage.sha256 )
log "install/root_uImage built: kernel $(stat -c%s "$WORK/kernel.bin") B, rootfs $(stat -c%s "$WORK/rootfs.squashfs") B, container $FINAL B"
