# Contributing

Contributions and feedback help make NoobWRT better for everyone.

## Report Bugs

1. Check if the issue already exists in the GitHub issue tracker.
2. If not, create a new issue.
3. Include the build tag, device model, reproduction steps, and logs or screenshots.

## Suggest Improvements

1. Open an issue with the `enhancement` label.
2. Describe the feature and why it would help the community.

## Firmware changes

Firmware definitions live in `firmware/`. Change the definition, package list or
overlay there and open a pull request against `main`. Do not change the builder
repository for device-specific behaviour.

Device overlays must not contain symlinks (the builder rejects them). File modes
are restored by `hooks/overlay.sh` from `overlay-baseline.json`; if you add a file,
add it to the baseline too.

## Issue Guidelines

- Use a clear, descriptive title.
- Provide as much detail as possible.
- Be respectful and constructive.
- Check for duplicates before posting.
