## after

- [install cgoban](https://www.gokgs.com/download.jsp)
- [install bypass paywalls](https://github.com/iamadamdev/bypass-paywalls-chrome)
- check adguard app https://adguard.com/en/compare.html?os=mac&_plc=en
- vagrant, minikube, packer
- grammarly, unarchiver
- tomighty (pomodoro), nordvpn cli
- https://github.com/cheat/cheat
- alacritty, zellij
- godoc
- npm, node
- rust

```
if ! type_exists 'rustup'; then
    p_header "- Installing Rust"
    rustup-init
    [[ $? ]] && p_success "Done"
fi

if [ ! -d ~/.cargo-target ]; then
    mkdir "${HOME}/.cargo-target"
fi
```

## wallpaper

```
{{ if eq .chezmoi.os "darwin" -}}
#!/bin/bash

echo "[dotfiles] Setting up wallpaper"
wallpaper set {{ joinPath .chezmoi.sourceDir "images/emma-francis-sea.jpg" }}
{{ end -}}
```

## nvm

```
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && source "$(brew --prefix)/opt/nvm/nvm.sh"
[ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && source "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"
```

## Cargo

```
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
```

## tmux

- https://github.com/tmux/tmux
- https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/
- https://danielmiessler.com/study/tmux/
- https://thoughtbot.com/blog/a-tmux-crash-course
