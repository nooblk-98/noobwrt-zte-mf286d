# Firmware definitions

Each `devices/<device>/variants/<variant>/firmware.json` is that variant's canonical
build recipe. Package selection is `packages.json`; extra kernel symbols are in
`kconfig`; router defaults are under `files/`; build-time logic is in `hooks/`.
Edit these files here, not in the builder.

The source and all feeds are locked to full commits. The Xray-core override also
uses a fixed version and SHA-256 pin in `hooks/prepare.sh`. Host compiler/container
dependencies and package downloads are not claimed bit-reproducible.

## Supported devices

### ZTE MF286D (`zte-mf286d`)

- Target: `ipq40xx/generic`, profile `zte_mf286d`
- OpenWrt baseline: `25.12.5` (`f0a60eee2fe051741c643ea6118718aae1ef17fb`)
- Variant: `passwall1` — luci-app-passwall with Xray-core `25.12.8`

## Device defaults provenance

The overlay in `variants/passwall1/files/` mirrors the reference image
`sysupgrade-zte_mf286d-20260618-1120.bin`
(SHA-256 `7cd8ca42302173d8b200760b1872f31c0b5576d84d98f0b2720c927ce938f52a`),
published by
[ilblogdicristiangallo](https://github.com/ilblogdicristiangallo/ZTE-MF286D-OpenWrt-25.12.4-by-ilblogdicristiangallo).

`overlay-baseline.json` records the source image, the per-file SHA-256 digests and
the modes that `hooks/overlay.sh` restores. It is a provenance record, not a
restriction against future firmware changes.

What is carried over:

- `/etc/config/network` — `br-lan` on `lan2 lan3 lan4`, QMI `wan` on
  `/dev/cdc-wdm0`, APN `internet`, DHCPv6 `wan6`
- `/etc/config/wireless` — channel/SSID/country defaults from the reference image
- `/etc/config/firewall` — simple LAN→WAN NAT setup
- `/etc/config/3ginfo`, `/etc/config/modemband`, `/etc/config/sms_tool_js` — modem
  tool defaults (`/dev/ttyUSB1`)
- `/etc/config/dhcp`, `dropbear`, `luci`, `rpcd`, `uhttpd` — stock defaults mirrored
  for parity (private files kept at `0600`)
- `/etc/uci-defaults/*` — the reference image's helper scripts
- `/sbin/sms_led.sh`, `/sbin/smstool_led.sh`, `/etc/init.d/my_new_sms` — SMS LED helper
- `/www/apn.html`, `/www/logo-apnweb.jpg`, `/www/cgi-bin/*` — APN web page assets
- `/etc/config/luci` + `/etc/uci-defaults/30_luci-theme-noobwrt` — NoobWRT theme as the
  default LuCI theme, with a toolbar limited to apps present in this build (no AW1000
  hostname/timezone/LED/network settings are imported)

Not carried over: `telegramWrt` (binary-only package) and the
`luci-app-modemband` application (no maintained source feed for 25.12). The
`/etc/config/modemband` file is kept so settings survive if the app is installed
later.

## Adding another router

Add a device/variant descriptor with its real OpenWrt target/subtarget/profile,
compatible packages, locked sources and necessary defaults. Do not copy MF286D
hooks into unrelated routers. The builder discovers output images from
`profiles.json`, not device-specific filenames. Only reviewed approved commits
should execute on the self-hosted runner; PRs do not automatically execute tests or
device hooks.

Definition validation is not a full compile or hardware flash test.
