#!/usr/bin/env bash
# Prepare phase: assert the feeds this variant depends on are present, then pin
# the PassWall1 Xray baseline (identical to the AW1000 PassWall1 variant).
set -euo pipefail

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
: "${BUILD_DIR:?BUILD_DIR must be set by the builder}"

require_dir() {
  [ -d "$1" ] || { echo "ERROR: missing feed package: $1" >&2; exit 1; }
}

PASSWALL_DIR=""
for candidate in \
  "$BUILD_DIR/feeds/noobwrt/feeds/passwall/luci-app-passwall" \
  "$BUILD_DIR/feeds/passwall/luci-app-passwall"; do
  if [ -f "$candidate/Makefile" ]; then
    PASSWALL_DIR="$candidate"
    break
  fi
done
[ -n "$PASSWALL_DIR" ] || { echo "ERROR: feed PassWall1 package missing" >&2; exit 1; }

require_dir "$BUILD_DIR/feeds/noobwrt/package/luci-app-3ginfo-lite"
require_dir "$BUILD_DIR/feeds/noobwrt/package/luci-app-sms-tool-js"

XRAY_MK="$BUILD_DIR/feeds/packages/net/xray-core/Makefile"
[ -f "$XRAY_MK" ] || { echo "ERROR: xray-core missing" >&2; exit 1; }
grep -q "^PKG_VERSION:=" "$XRAY_MK"
grep -q "^PKG_HASH:=" "$XRAY_MK"
sed -i \
  -e "s/^PKG_VERSION:=.*/PKG_VERSION:=25.12.8/" \
  -e "s/^PKG_HASH:=.*/PKG_HASH:=d4519b2d9bb1871f4d7612aa7a8db1c451573b5a44ac824219bb44d63f404e61/" \
  "$XRAY_MK"
echo "xray-core pinned: 25.12.8 (PassWall1 baseline)"
