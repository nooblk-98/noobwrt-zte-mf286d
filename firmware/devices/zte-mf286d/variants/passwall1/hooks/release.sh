#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
bash "$HERE/generate-release.sh" "$BUILD_JSON" "$RUN_OUTPUT"

# ZTE stock-flash container (no serial cable). Non-fatal: the firmware images and
# release notes are already produced.
sh "$HERE/scripts/make-root-uimage.sh" || echo "root_uimage: generation failed; firmware images unaffected" >&2

# The MF286D rootfs partition is 29 MiB; 230 usable LEBs are 29,204,480 bytes and
# the kernel is stored uncompressed inside that area. Refuse to publish an image
# that cannot be flashed, and warn when the overlay would be starved.
MAX_IMAGE_BYTES=27850000
SAFE_IMAGE_BYTES=25500000

fail=0
while IFS= read -r -d '' img; do
  size=$(stat -c%s "$img")
  name=$(basename "$img")
  if [ "$size" -gt "$MAX_IMAGE_BYTES" ]; then
    echo "ERROR: $name is $size bytes, over the 29 MiB UBI budget ($MAX_IMAGE_BYTES)" >&2
    fail=1
  elif [ "$size" -gt "$SAFE_IMAGE_BYTES" ]; then
    echo "WARNING: $name is $size bytes; overlay space will be very small" >&2
  else
    echo "size check: $name $size bytes (ok)"
  fi
done < <(find "$RUN_OUTPUT" -maxdepth 1 -name '*sysupgrade*.bin' -print0 2>/dev/null)

[ "$fail" -eq 0 ] || {
  echo "ERROR: firmware does not fit the ZTE MF286D flash layout; trim packages.json" >&2
  exit 1
}
