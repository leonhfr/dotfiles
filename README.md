# dotfiles

Your dotfiles are how you personalize your system, these are mine.

Managed with [`chezmoi`](https://github.com/twpayne/chezmoi).

```sh
# Run, then open a new terminal.
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply leonhfr
```

Locally, the dotfiles source directory lives in `~/.local/share/chezmoi`.

## Sign in

- 1Password
- Firefox + Extensions
- Spotify
- Claude
- Filen
- NordVPN

## Set up

```sh
# Set up FileVault and enable firewall
mise run setup
```

- Rectangle
- Handy
- Obsidian Notes
- Filen
  - Pictures
  - Calibre Library
- Calibre
- Mochi

## OMP profiles

`~/.zprofile` sets `OMP_PROFILE` to the chezmoi machine type, so plain `omp`
uses the matching named profile:

- `personal` → `~/.omp/profiles/personal/agent`
- `work` → `~/.omp/profiles/work/agent`

Chezmoi deploys only the matching isolated profile. Shared instructions and
skills live under `~/.agents` and are symlinked into Claude; OMP discovers the
common agent layout natively without importing Claude configuration.

Profile settings are managed, while authentication, sessions, caches, and
memory remain local. On a new machine, apply the dotfiles and run `omp login`;
work setup also reconciles plugins and requires MCP authorization in OMP.

## Install manually

- [CGoban](https://www.gokgs.com/download.jsp)
