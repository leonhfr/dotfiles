# random

## firefox

- https://www.chezmoi.io/docs/reference/#mozillainstallhash-path
- https://github.com/twpayne/chezmoi/issues/1226

## multiple git accounts

- https://medium.com/@ibrahimlawal/developing-with-multiple-github-accounts-on-one-macbook-94ff6d4ab9ca
- https://stackoverflow.com/questions/3860112/multiple-github-accounts-on-the-same-computer
- https://github.com/cli/cli/issues/326#issuecomment-941024372
- https://direnv.net/
- https://github.com/alecthomas/ondir

## karabiner

- [Karabiner Elements](https://karabiner-elements.pqrs.org/docs/)
- [twpayne config](https://github.com/twpayne/dotfiles/blob/master/private_dot_config/private_karabiner/private_karabiner.json)

## linux

- https://www.chezmoi.io/docs/how-to/#handle-different-file-locations-on-different-systems-with-the-same-contents

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
