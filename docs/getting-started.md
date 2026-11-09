# Getting Started

!!! note "First Boot Checklist"

1. Power on the device and wait for the system to boot fully.
2. Connect a client to `lan2`, `lan3` or `lan4`, or join the Wi-Fi.
3. Open the web UI in a browser: `http://192.168.1.1`.

## Default Access

- Admin username: `root`
- Admin password: not set on first boot
- Default LAN IP: `192.168.1.1`
- Default SSID (2.4 GHz): `OpenWrt-2.4Ghz`
- Default SSID (5 GHz): `OpenWRT-5Ghz`
- Wi-Fi security: open (no password) until you configure it

!!! warning "Secure the router immediately"
    The reference defaults ship an open Wi-Fi and an empty root password. Set a
    root password and WPA2/WPA3 key before connecting the router to the internet.

## Ports

| Port | Role |
|---|---|
| `lan1` | Ethernet WAN (default WAN uplink) |
| `lan2`, `lan3`, `lan4` | LAN, bridged into `br-lan` |

The LTE modem is the primary WAN in the shipped config: `wan` is a QMI interface
on `/dev/cdc-wdm0` with APN `internet`. If you want Ethernet WAN instead, change
`network.wan` to `proto dhcp` on device `lan1`.

## First things to change

1. **Root password** — `System` → `Administration`.
2. **Wi-Fi country, SSID and key** — `Network` → `Wireless`.
3. **APN** — `http://192.168.1.1/apn.html` or `Network` → `Interfaces` → `wan`.
4. **Timezone** — `System` → `System` → `General Settings`.

## Modem tools

| Tool | Where |
|---|---|
| Signal / operator info | `Modem` → `3ginfo` |
| SMS | `Modem` → `SMS Tool JS` |
| APN quick page | `http://192.168.1.1/apn.html` |
| ModemManager CLI | `mmcli -L`, `mmcli -m 0` |
