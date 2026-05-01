# try later

- https://github.com/manaflow-ai/cmux
- https://github.com/MemPalace/mempalace
- https://github.com/rtk-ai/rtk
- https://github.com/aaif-goose/goose
- [install bypass paywalls](https://github.com/iamadamdev/bypass-paywalls-chrome)
- check adguard app https://adguard.com/en/compare.html?os=mac&_plc=en
- zellij
- https://github.com/jonas-grgt/ktea
- https://github.com/loov/goda
- https://github.com/tailscale/tailscale
- https://github.com/tmux/tmux

## references

- https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap
- finder sidebar management, https://github.com/mosen/mysides/issues/37

## wallpaper

```
{{ if eq .chezmoi.os "darwin" -}}
#!/bin/bash

echo "[dotfiles] Setting up wallpaper"
wallpaper set {{ joinPath .chezmoi.sourceDir "images/emma-francis-sea.jpg" }}
{{ end -}}
```
