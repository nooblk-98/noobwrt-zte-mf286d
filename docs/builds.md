# Firmware Releases

## Maintainer builds (current)

Maintainer builds are delivered privately in Google Drive. This build path
creates no GitHub Actions artifacts and no automatic GitHub releases.

Start one from **Actions → Build Firmware** on `main`: enter a new `build_tag`.
To test the dispatch and delivery transport without compiling, run it once with
`validate_only=true` and a separate unused tag. Files land unzipped at
`ROOT/passwall1/<build_tag>/`:

- `images/` — individual firmware images
- `metadata/` — build details, profiles, package and source pins
- `logs/` — build log
- `SHA256SUMS`, `result.json`, `COMPLETE.json` — checksums and receipts

Access stays private; links do not grant access.

## Images produced

The `zte_mf286d` profile uses the default `ipq40xx/generic` image recipe, so a
build produces one image:

| Image | Use |
|---|---|
| `openwrt-ipq40xx-generic-zte_mf286d-squashfs-sysupgrade.bin` | Upgrading an existing OpenWrt / NoobWRT installation |

First-time installation from stock firmware uses an **initramfs** image (see
[Installation](installation.md)); it is not part of the standard build output.

## Notes

- Use the `sysupgrade.bin` image to upgrade an existing installation.
- Current builds use OpenWrt 25.12 with the **APK** package manager (not opkg).
- The variant pins OpenWrt `25.12.5`, the OpenWrt feeds and
  `noobwrt-custom-feeds` to full commits; see `firmware.json`. Upstream currently
  lists `25.12.6` as the supported release for this device — this build stays on
  `25.12.5` to match the NoobWRT AW1000 baseline, and bumps together.
- Xray-core is pinned to `25.12.8` by `hooks/prepare.sh`. Do not upgrade it
  yourself; the bundled version is what the PassWall 1 build is tested with.
