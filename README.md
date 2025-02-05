# github.com/leonhfr/dotfiles

your dotfiles are how you personalize your system, these are mine

managed with [`chezmoi`](https://github.com/twpayne/chezmoi)

install:

1. install [1password cli](https://1password.com/downloads/command-line/) and move `op` to `/usr/local/bin` or somewhere in the PATH

2. in a terminal:

```sh
# sign in
op signin my.1password.com hello@leonhfr.fr

# set environment variable
eval $(op signin --account my)

# install chezmoi, pull this repo and apply the changes
sh -c "$(curl -fsLS git.io/chezmoi)" -- init --apply leonhfr

# in the future, pull and apply the latest changes
chezmoi update
```

locally, the dotfiles source directory lives in `~/.local/share/chezmoi`

inspired by dotfiles from:

- [broucz](https://github.com/broucz/dotfiles)
- [twpayne](https://github.com/twpayne/dotfiles)
- [mathiasbynens](https://github.com/mathiasbynens/dotfiles)

## after

- [install cgoban](https://www.gokgs.com/download.jsp)
- [install bypass paywalls](https://github.com/iamadamdev/bypass-paywalls-chrome)
- set up Rectangle
