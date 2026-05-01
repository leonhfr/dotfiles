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
# FileVault, store the recovery key in 1Password
sudo fdesetup enable

# Firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
```

- Rectangle
- 1Password: Settings -> Developer -> Use the SSH agent
- Handy
- Obsidian Notes
- Filen
  - Pictures
  - Calibre Library
- Calibre
- Mochi

## Install manually

- [CGoban](https://www.gokgs.com/download.jsp)
