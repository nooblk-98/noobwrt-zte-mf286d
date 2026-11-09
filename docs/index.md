# NoobWRT for ZTE MF286D

NoobWRT is a curated OpenWrt firmware build for the ZTE MF286D. It focuses on a
predictable LTE router setup: a working QMI/ModemManager data path, PassWall 1,
sensible Wi-Fi and firewall defaults, and a small set of modem tools.

## Announcements

!!! info "PassWall 1 only"
    This repository ships a single reviewed variant, **passwall1**. There is no
    PassWall 2 build for the MF286D.

!!! success "NoobWRT theme"
    The **NoobWRT theme** is the default LuCI UI. Only the toolbar entries this
    build actually provides are enabled (Home, Modem, SMS, Wireless, Firewall,
    VPN, System Log, Settings); device defaults such as hostname, timezone,
    network and LEDs are not overridden.

!!! warning "Reference image defaults"
    The device overlay reproduces the defaults of the community ZTE MF286D image
    (`sysupgrade-zte_mf286d-20260618-1120.bin`). That includes Wi-Fi country `IT`
    and SSID names `OpenWrt-2.4Ghz` / `OpenWRT-5Ghz`. Change them in LuCI before
    deploying the router.

## Scope

This documentation covers the MF286D build definition, image layout, installation
and recovery workflows, and the package set. For general OpenWrt usage, refer to
the [OpenWrt documentation](https://openwrt.org/docs/start).

## Repository layout

| Path | Purpose |
|---|---|
| `firmware/devices/zte-mf286d/variants/passwall1/firmware.json` | Canonical build recipe (source, feeds, target, hooks) |
| `firmware/devices/zte-mf286d/variants/passwall1/packages.json` | Package add/remove lists |
| `firmware/devices/zte-mf286d/variants/passwall1/files/` | Device overlay (UCI defaults, helpers, APN page) |
| `firmware/devices/zte-mf286d/variants/passwall1/hooks/` | Prepare/configure/overlay/release hooks |
| `firmware/devices/zte-mf286d/variants/passwall1/overlay-baseline.json` | Provenance and file modes of the overlay |
| `scripts/` | Build dispatch and request validation |
