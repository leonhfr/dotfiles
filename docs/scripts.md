### Simple aliases

```
# navigation aliases
alias dev="cd ~/dev/"
alias personal="cd ~/dev/thorstenhans"
alias business="cd ~/dev/thinktecture"

# kubectl aliases
alias k="kubectl"
alias kgx="kubectl config get-contexts"

# docker aliases
alias d="docker"
alias dps="docker ps"
```

## ssh

```sh
cd ~/.ssh
ssh-keygen -m pem -t rsa -b 2048 -C "lhollender@userzoom.com" -f "github-lhollender-uz"
ssh-keygen -m pem -t rsa -b 2048 -C "hello@leonh.fr" -f "github-leonhfr"
pbcopy < ~/.ssh/github-lhollender-uz.pub
pbcopy < ~/.ssh/github-leonhfr.pub
ssh-add -K ~/.ssh/github-lhollender-uz
ssh-add -K ~/.ssh/github-leonhfr
```

### Clean git repository

```
git clean -nx
# n: dry run
# d: directories as well
# f: for real
```

### Sort by file size

```
alias lt='ls --human-readable --size -1 -S --classify'
```

### Find a command in your grep history

```
alias gh='history|grep'
```

### Sort by modification time

```
alias left='ls -t -1'
```

## references

- [install python](https://github.com/nicolashery/mac-dev-setup#python)
- [general mac setup](https://sourabhbajaj.com/mac-setup/)
- [vscode defaults](https://code.visualstudio.com/docs/getstarted/settings#_default-settings)

## todos

- TODO: pre commit hook to check for secrets
- TODO: regenerate ssh keys without passphrase
