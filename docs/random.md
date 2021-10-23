# random

## firefox

- https://www.chezmoi.io/docs/reference/#mozillainstallhash-path
- https://github.com/twpayne/chezmoi/issues/1226

## karabiner

- [Karabiner Elements](https://karabiner-elements.pqrs.org/docs/)
- [twpayne config](https://github.com/twpayne/dotfiles/blob/master/private_dot_config/private_karabiner/private_karabiner.json)

## rsync

```shell
# dry run
rsync -anPv Documents/Pictures/ /media/HDD/Pictures/
# for real
rsync -aPv Documents/Pictures/ /media/HDD/Pictures/
# even better
rsync -avh source/ dest/ --delete
```

## tmux

- https://github.com/tmux/tmux
- https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/
- https://danielmiessler.com/study/tmux/
- https://thoughtbot.com/blog/a-tmux-crash-course
