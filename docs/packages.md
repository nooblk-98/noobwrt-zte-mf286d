# Packages

This page lists the packages selected by
`firmware/devices/zte-mf286d/variants/passwall1/packages.json` on top of the
OpenWrt `ipq40xx/generic` `zte_mf286d` profile.

The profile itself already adds `kmod-usb-net-qmi-wwan`, `kmod-usb-serial-option`
and `uqmi`.

!!! warning "Size budget"
    The MF286D has a **29 MiB** firmware partition (about 24.5 MiB usable for the
    rootfs after the kernel). The build is deliberately slim: Xray is the only
    proxy core, and there are no NAS, Samba, NFS, media-server or desktop CLI
    packages. See [Hardware](hardware.md#flash-and-image-size-budget).

## Added packages

### LuCI and theme

```text
luci
luci-app-package-manager
luci-theme-noobwrt
luci-app-3ginfo-lite
luci-app-sms-tool-js
luci-app-passwall
luci-proto-qmi
luci-proto-mbim
luci-proto-modemmanager
luci-proto-wireguard
```

### Modem / mobile broadband

```text
modemmanager
umbim
uqmi
comgt
usb-modeswitch
usbutils
kmod-usb-net
kmod-usb-net-qmi-wwan
kmod-usb-net-cdc-mbim
kmod-usb-serial
kmod-usb-serial-option
kmod-usb-serial-wwan
kmod-usb-wdm
kmod-usb-dwc3
kmod-usb-dwc3-qcom
kmod-usb3
```

### Wi-Fi

```text
kmod-ath10k-ct
ath10k-board-qca4019
ath10k-firmware-qca4019-ct
wpad-mbedtls
```

### PassWall 1 (Xray only)

```text
chinadns-ng
dns2socks
dns2tcp
microsocks
xray-core
tcping
resolveip
```

### Firewall / nftables

```text
kmod-nft-core
kmod-nft-nat
kmod-nft-socket
kmod-nft-tproxy
kmod-nf-conntrack
kmod-nf-conntrack6
kmod-nf-log
kmod-nf-log6
kmod-nf-nat
kmod-nf-reject
kmod-nf-reject6
kmod-nf-socket
kmod-nf-tproxy
kmod-nfnetlink
kmod-inet-diag
kmod-netlink-diag
dnsmasq-full
firewall4
nftables
ip-full
```

### Tunnels and tuning

```text
kmod-wireguard
wireguard-tools
kmod-tun
kmod-tcp-bbr
```

### System

```text
odhcp6c
odhcpd-ipv6only
ppp
ppp-mod-pppoe
mtd
uboot-envtools
```

### Small CLI tools

```text
curl
wget-ssl
ca-bundle
jq
```

## Removed packages

```text
dnsmasq
firewall
firewall3
iptables
iptables-nft
iptables-mod-tproxy
iptables-mod-conntrack-extra
iptables-mod-ipopt
kmod-ipt-core
kmod-ipt-nat
https-dns-proxy
luci-app-https-dns-proxy
wpad-basic-mbedtls
```

## Deliberately not included

| Package | Why |
|---|---|
| `sing-box`, `v2ray-geoip`, `v2ray-geosite`, `haproxy` | ~21 MiB together; would not fit |
| `luci-app-modemband` | no maintained source feed for 25.12 (config kept) |
| `apn-web`, `telegramWrt` | binary-only upstream; APN page ships in the overlay |
| samba4, nfs, minidlna, filemanager, sftp-server | NAS features not wanted on this build |
| bash, coreutils, htop, tcpdump, gawk, nano, less, unzip, ethtool-full | desktop conveniences, cut to protect the size budget |

## Notes

- `dnsmasq-full` replaces `dnsmasq` so PassWall's nftset support works.
- `wpad-mbedtls` replaces `wpad-basic-mbedtls` for WPA3 and 802.11w.
- `luci-theme-noobwrt` is the default theme; `/etc/config/luci` points
  `mediaurlbase` at `/luci-static/noobwrt`.
