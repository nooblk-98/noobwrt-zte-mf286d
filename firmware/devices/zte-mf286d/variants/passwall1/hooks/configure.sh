#!/usr/bin/env bash
# Configure phase: guard the target the definition was written for.
set -euo pipefail
: "${BUILD_DIR:?BUILD_DIR must be set by the builder}"

[ -f "$BUILD_DIR/target/linux/ipq40xx/Makefile" ] || {
  echo "ERROR: ipq40xx target missing from source checkout" >&2
  exit 1
}
[ -f "$BUILD_DIR/target/linux/ipq40xx/image/generic.mk" ] || {
  echo "ERROR: ipq40xx generic subtarget missing" >&2
  exit 1
}
grep -q "Device/zte_mf286d" "$BUILD_DIR/target/linux/ipq40xx/image/generic.mk" || {
  echo "ERROR: zte_mf286d device definition missing upstream" >&2
  exit 1
}
echo "configure: ipq40xx/generic zte_mf286d present"
