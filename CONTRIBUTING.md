# Contributing

Thanks for helping improve NoobWRT for the ZTE MF286D.

## Where changes belong

| Change | Location |
|---|---|
| Device defaults, UCI configs, helper scripts | `firmware/devices/zte-mf286d/variants/passwall1/files/` |
| Package selection | `firmware/devices/zte-mf286d/variants/passwall1/packages.json` |
| Build source / feed pins | `firmware/devices/zte-mf286d/variants/passwall1/firmware.json` |
| Kernel symbols | `firmware/devices/zte-mf286d/variants/passwall1/kconfig` |
| Build-time logic | `firmware/devices/zte-mf286d/variants/passwall1/hooks/` |

Do not change the [builder](https://github.com/NoobWRT/noobwrt-builder) for
device-specific behaviour.

## Rules for the overlay

- No symlinks; the builder rejects overlays containing them.
- File modes are restored from `overlay-baseline.json`. If you add or change a
  file, regenerate the baseline so `hooks/overlay.sh` keeps the modes correct.
- Keep private configs at mode `0600` and helper scripts at `0755`.
- Keep the overlay limited to defaults. Runtime state belongs on the device, not
  in the repository.

## Pull requests

1. Open an issue describing the problem or improvement.
2. Keep the change focused on one concern.
3. Describe how you verified it (a definition validation run, a build tag, or a
   device test).
4. Do not include secrets, credentials or private keys.

## Reporting bugs

Include the build tag, what you expected, what happened, and the relevant system
and kernel logs.
