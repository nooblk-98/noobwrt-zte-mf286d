# Modem Firmware

The MF286D uses an mPCIe **Cat 12** LTE module (MDM9250 based) connected over QMI.
OpenWrt talks to it through `/dev/cdc-wdm0`.

## Check the current modem version

Connect to the modem AT port (usually `/dev/ttyUSB1`) with `picocom`, `minicom` or
`gcom` and send `ATI`:

```text
Manufacturer: ZTE CORPORATION
Model: MF286DMODULE
Revision: BD_TELIAMF286DV1.0.0B11
SVN: 11
IMEI: 86XXXXXX
+GCAP: +CGSM,+DS
```

The revision suffix (`...B11` here) is the modem build. The community reports that
**B12** is the stable build for OpenWrt; older builds can drop the data connection.

## Updating the modem to B12 (community procedure)

The update runs from OpenWrt, over ADB to the modem's `/cache` plus AT commands.
Updates are **sequential**: B03 → B06 → B11 → B12, one step at a time.

1. Install `adb` on the router (`apk add android-tools` or an equivalent package).
2. Extract the matching `imageBxxnaByy` folder from the community "Nordic Modem
   Update (up to B12)" package. It contains `delta.package` and `delta.signature`.
3. Push both files to the modem:

```sh
adb push delta.package /cache/
adb push delta.signature /cache/
```

4. On the AT port (`/dev/ttyUSB1`), step through the update:

```text
at+fotactr=0     # 0,0  -> modem sees the package
at+fotactr=1     # 1,0  -> validation ok (1 = failed, 2 = waiting)
at+fotactr=5     # 5,<bytes> -> size of the update package
at+fotactr=8     # 8,0  -> clears old *.flg files in /cache
at+fotactr=2     # starts the update
```

5. Wait about five minutes; the modem reboots and comes back.
6. Repeat for the next step until B12, then reboot once more and re-check `ATI`.

Source: [makebit/mf286d-openwrt](https://github.com/makebit/mf286d-openwrt) and the
original thread on [eko.one.pl](https://eko.one.pl/forum/viewtopic.php?pid=285899#p285899).

!!! warning
    A failed modem flash can leave the module without a working firmware. Do not
    interrupt power, and do not skip intermediate versions.

## What this firmware does not do

NoobWRT does **not** flash modem firmware. The modem keeps whatever build the
device shipped with. There is no tested, reversible modem upgrade path maintained
in this repository.

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
