# Additional Packages

Current NoobWRT builds use OpenWrt 25.12 with the **APK** package manager. Old
`.ipk` packages and `opkg` commands do not work on these builds.

Only install packages built for OpenWrt 25.12 and the
`arm_cortex-a7_neon-vfpv4` architecture. Kernel modules (`kmod-*`) must match the
exact kernel version of your firmware.

## Install Steps

1. Download the `.apk` file you need.
2. Upload it to the router, for example into `/tmp`.
3. Install over SSH:

```sh
apk add --allow-untrusted /tmp/package-name.apk
```

## Install via Web UI

1. Go to `System` then `Software`.
2. Click `Upload Package`.
3. Select the `.apk` file.
4. Click `Install`.

## Verify

```sh
apk list --installed | grep package-name
```

## Feed repositories

The reference image used these extra APK repositories:

```text
https://github.com/4IceG/Modem-extras-apk/raw/refs/heads/main/myapk/packages.adb
https://github.com/ilblogdicristiangallo/ilblogdicristiangallo_repo_openwrt_APK/raw/refs/heads/main/packages.adb
```

They are not added by default in this build. Add them only if you need their
packages, and remember they are third-party, unsigned-for-you repositories.

!!! warning
    The kernel of a NoobWRT build comes from the pinned OpenWrt commit in
    `firmware.json`. Third-party `kmod-*` packages built for a different kernel
    revision will not load.
