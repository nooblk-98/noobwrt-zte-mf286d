# Modem Firmware

The MF286D uses an mPCIe **Cat 12** LTE module (MDM9250 based) connected over QMI.
OpenWrt talks to it through `/dev/cdc-wdm0`.

## What this firmware does not do

NoobWRT does **not** flash modem firmware. The modem keeps whatever firmware the
device shipped with. There is no tested, reversible modem-firmware upgrade path for
this model in this repository.

## Checking the modem

```sh
# QMI mode / device presence
ls -l /dev/cdc-wdm0
uqmi -d /dev/cdc-wdm0 --get-version

# ModemManager view
mmcli -L
mmcli -m 0

# Signal and operator (3ginfo uses the same AT port)
sms_tool -d /dev/ttyUSB1 status
```

The reference image points the 3ginfo and modemband apps at `/dev/ttyUSB1`. If your
modem enumerates on a different AT port, change:

```sh
uci set 3ginfo.@3ginfo[0].device='/dev/ttyUSB2'
uci set modemband.@modemband[0].set_port='/dev/ttyUSB2'
uci commit
```

## Switching the WAN protocol

The shipped config uses QMI. ModemManager and MBIM are also available:

```sh
# ModemManager
uci set network.wan.proto='modemmanager'
uci set network.wan.device='/dev/cdc-wdm0'
uci commit network
/etc/init.d/network restart
```

The APN page (`/apn.html`) can switch between QMI, MBIM and ModemManager and write
the APN for you.

!!! warning
    Changing the modem protocol can drop your connection until the APN and device
    path are correct. Keep serial or LAN access while testing.
