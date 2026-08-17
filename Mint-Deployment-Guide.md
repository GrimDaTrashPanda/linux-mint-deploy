# Linux Mint Deployment Guide — Background and Rationale

This document explains the *why* behind `deploy.sh`. The script is the thing you run; this is the thing you read once if you want to know what it's doing and why it's doing it that way.

## Why Mint gets its own script instead of reusing debian-deploy

Mint is Ubuntu-based, and Ubuntu is Debian-based, so on paper it's "the same family." In practice, three things differ enough to matter:

1. **Repo defaults.** Debian ships minimal by default — `non-free-firmware` and similar components often need to be added manually. Mint (via Ubuntu) enables `universe`/`multiverse` out of the box, so packages like VLC that need an extra step on Debian just work here.
2. **Flatpak.** Debian needs Flathub added from scratch. Mint ships flatpak installed with Flathub already configured — the script confirms this instead of blindly re-adding it.
3. **Desktop environment.** Debian's script (and this whole deploy family) has assumed GNOME/Wayland. Mint's default is Cinnamon on X11 — so there's no `MOZ_ENABLE_WAYLAND` step, no `ozone-platform-hint` flag-flipping in each browser. One less post-install step, not a missing one.

Everything else — the browser-stack logic, the split-update launcher pattern, the idempotent re-run safety — carries over from `debian-deploy` basically unchanged, because it's genuinely the same apt-based mechanics underneath.

## Prerequisites

- Linux Mint already installed (Cinnamon edition — this is the standard/default edition; MATE and Xfce editions use different desktop-specific bits and aren't covered here)
- A working internet connection for the initial apt and repo setup

## Rebuild order (if pairing with other repos)

This script only covers OS-level baseline provisioning — toolkit, browsers, update workflow. It does **not** touch theming/rice or personal file restoration. If you build out a Mint-specific rice or loadout snapshot later (following the `riced-potatoes` / `clone-panda-msi` pattern), the order would be:

1. Fresh Mint install
2. Run `mint-deploy` (this repo) — baseline toolkit + browsers
3. Any theming/rice repo, if one exists
4. Restore personal files from external storage

## Status

This is a first pass, written from known Mint/Ubuntu conventions rather than tested against a live install (no Mint machine in current rotation). Flag anything that breaks on an actual run — this is exactly the kind of thing that needs a real-world pass before it's fully trustworthy.
