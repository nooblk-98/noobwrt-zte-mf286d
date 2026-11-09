# Packages

This page lists the packages selected by
`firmware/devices/zte-mf286d/variants/passwall1/packages.json` on top of the
OpenWrt `ipq40xx/generic` `zte_mf286d` profile.

The profile itself already adds `kmod-usb-net-qmi-wwan`, `kmod-usb-serial-option`
and `uqmi`.

## Added packages

### LuCI and management

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

### PassWall 1 stack

```text
haproxy
chinadns-ng
dns2socks
dns2tcp
microsocks
sing-box
xray-core
v2ray-geoip
v2ray-geosite
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

### Tuning and tunnels

```text
kmod-wireguard
wireguard-tools
kmod-sched
kmod-netem
kmod-tcp-bbr
kmod-tun
```

### Storage / system

```text
block-mount
odhcp6c
odhcpd-ipv6only
ppp
ppp-mod-pppoe
mtd
uboot-envtools
openssh-sftp-server
```

### CLI tools

```text
curl
wget-ssl
ca-bundle
jq
tcpdump
less
nano
htop
bash
coreutils
coreutils-base64
coreutils-nohup
coreutils-sort
coreutils-stty
gawk
grep
sed
unzip
ethtool-full
```

## Removed packages

These are disabled so the PassWall 1 stack owns the firewall/DNS path:

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

## Notes

- `dnsmasq-full` replaces `dnsmasq` so PassWall's `ipset`/`nftset` support works.
- `wpad-mbedtls` replaces `wpad-basic-mbedtls` for WPA3 and 802.11w support.
- `luci-theme-noobwrt` is the default theme; `/etc/config/luci` points `mediaurlbase` at
  `/luci-static/noobwrt` and `etc/uci-defaults/30_luci-theme-noobwrt` seeds the toolbar.
- The reference image also included `luci-app-modemband`, `apn-web` and
  `telegramWrt`. `luci-app-modemband` has no maintained source feed for 25.12, and
  `apn-web` / `telegramWrt` are binary-only; the APN page assets are shipped in the
  overlay instead, and `/etc/config/modemband` is kept so band settings survive if
  you install the app later.
