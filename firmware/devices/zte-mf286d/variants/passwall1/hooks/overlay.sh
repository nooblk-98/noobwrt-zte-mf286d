#!/usr/bin/env bash
# Overlay phase: restore the file modes recorded from the reference ZTE MF286D
# image. Git only tracks the executable bit, so private configs are re-tightened
# here instead of being committed as world-readable.
set -euo pipefail

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
: "${BUILD_DIR:?BUILD_DIR must be set by the builder}"
FILES="$BUILD_DIR/files"
[ -d "$FILES" ] || { echo "ERROR: overlay directory missing" >&2; exit 1; }

python3 - "$HERE/overlay-baseline.json" "$FILES" <<'PY'
import json
import os
import sys

baseline_path, files_root = sys.argv[1], sys.argv[2]
baseline = json.load(open(baseline_path))
missing = []
for rel, meta in baseline["files"].items():
    path = os.path.join(files_root, rel)
    if not os.path.isfile(path):
        missing.append(rel)
        continue
    os.chmod(path, meta["mode"])
if missing:
    raise SystemExit("ERROR: overlay files missing: " + ", ".join(missing))
print(f"overlay: restored modes for {len(baseline['files'])} files")
PY
