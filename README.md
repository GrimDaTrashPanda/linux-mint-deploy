# Linux Mint Baseline Deployment

A single, idempotent script that takes a fresh Linux Mint install (Cinnamon) to a fully provisioned baseline: native toolkit, full browser stack, and a split-phase update workflow with desktop launchers.

Full background and rationale: [`Mint-Deployment-Guide.md`](./Mint-Deployment-Guide.md)

Mint is Ubuntu-based, so it shares apt with `debian-deploy`, but the repo landscape and defaults differ enough to need its own script rather than reusing Debian's as-is.

## Prerequisites

- Linux Mint already installed (Cinnamon edition assumed — the standard, most common edition)
- An internet connection for the initial apt and repo setup

## Usage

```bash
git clone https://github.com/GrimDaTrashPanda/linux-mint-deploy.git
cd linux-mint-deploy
chmod +x deploy.sh
./deploy.sh
```

Run as your normal user, not root — it calls `sudo` internally where needed.

## What it does

- Detects CPU vendor and installs the matching microcode package (`intel-microcode` / `amd64-microcode`)
- Installs the native toolkit: `firefox`, `telegram-desktop`, `shotcut`, `gimp`, `glances`, `vlc`, `p7zip-full`, plus build tooling
- Fetches `fastfetch` and `duf` directly from their GitHub releases — neither is reliably current in Mint's base repos
- Confirms Flathub is configured (Mint ships it preconfigured by default, unlike Debian/Ubuntu — this checks rather than assumes)
- Installs Chrome (direct `.deb`), Brave (official install script), and Edge (official apt repo) — each browser uses a different install mechanism, same as `debian-deploy`
- Creates `update-core.sh` / `update-apps.sh` and matching desktop launchers

## How package sources break down on Mint

| Source | Detail |
|---|---|
| Official apt packages | Everything from Mint/Ubuntu's own repos — most of the toolkit, including VLC (Mint enables universe/multiverse by default, unlike Debian) |
| Third-party apt repos | Brave and Edge each add their own repo; once added, apt treats them like official packages |
| Direct `.deb` installs | Chrome ships no apt repo by default, so it's installed from a downloaded `.deb` |
| GitHub-release binaries | `fastfetch` and `duf` aren't reliably packaged for Mint, so they're fetched directly from their GitHub releases |
| Flatpak | Preconfigured out of the box on Mint — this script confirms it rather than setting it up from scratch |

## After running

- Press Super, search "Update" — confirm both launchers appear
- No Wayland step — Mint Cinnamon runs X11 by default, unlike `endeavouros-deploy`
- If you want `tldr`: `sudo apt install node-tldr` or `pip install tldr`

## Safe to re-run

Every install step checks for an existing binary or repo file before acting. Re-running won't duplicate repo entries or reinstall already-current packages.

## A note on the "split update" naming

Same as `debian-deploy`: apt doesn't cleanly separate "trusted official" from "third-party repo" packages, so `update-core.sh` really covers everything apt-tracked (including Brave/Edge once added), and `update-apps.sh` only covers Flatpak. Kept as two launchers for a consistent update habit across machines, not because the split is deeply meaningful on Mint itself.
