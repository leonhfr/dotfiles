# borg

## setup

```sh
# no passphrase
ssh-keygen -m pem -t rsa -b 2048 -C "hello@leonh.fr" -f "rsync-borgbackup"
# add private key to keychain
ssh-add -K ~/.ssh/rsync-borgbackup
# upload public key
scp ~/.ssh/rsync-borgbackup.pub zh1820@zh1820.rsync.net:.ssh/authorized_keys
# test connection, should not be asked for a password
ssh zh1820@zh1820.rsync.net ls
```

## borg

```sh
# init repo
borg init --remote-path=borg1 \
  --make-parent-dirs \
  -e repokey-blake2 \
  zh1820@zh1820.rsync.net:macos/Official
# create first backup
borg create --remote-path=borg1 \
  --progress --stats \
  zh1820@zh1820.rsync.net:macos/Official::backup-init ~/Official
```

## scripts

```sh
export BORG_PASSPHRASE="passphrase"
export BORG_REPO="zh1820@zh1820.rsync.net:macos/Official"
borg create ::$(hostname)-$(date '+%Y-%m-%d') ~/Official
```

## alternatives

- [tarsnap](https://www.tarsnap.com/)
