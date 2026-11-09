# Other ZTE MF286 models

The MF286 name covers several different boards. Only **MF286D** is supported by
this repository.

| Model | SoC | OpenWrt target | Status here |
|---|---|---|---|
| **MF286D** | Qualcomm IPQ4019 | `ipq40xx/generic`, profile `zte_mf286d` | **this repository** |
| MF286 / MF286A / MF286AR / MF286C / MF286R | Qualcomm QCA9563 | `ath79/nand`, profiles `zte_mf286*` | different hardware — not this build |

Images, DTS and packages are **not interchangeable** between these models. Flashing
an MF286A/AR/C/R image on an MF286D (or the reverse) will not boot.

## Globe At Home MF286RA guide (video)

A community walkthrough for the Philippine **Globe At Home MF286RA**:

[ZTE MF286RA OpenWrt Firmware Installation Beginner's Guide — INKfinite](https://youtu.be/GU-b3ekzkOw)

!!! warning "Different router"
    That video targets the **ath79/QCA9563 MF286RA**, not the IPQ4019 MF286D. The
    files it links (behind a Rekonise unlock page) are built for `ath79/nand`
    `zte_mf286*` and must not be used on an MF286D.

The general shape of the procedure is the same as here — serial console, initramfs
over TFTP, then sysupgrade — but the image, partition layout and UART pinout come
from the ath79 device page, not this one.
