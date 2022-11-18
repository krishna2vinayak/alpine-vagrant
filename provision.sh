#!/bin/ash
set -euxo pipefail

cat >>/etc/apk/repositories <<'EOF'
https://dl-cdn.alpinelinux.org/alpine/latest-stable/main
https://dl-cdn.alpinelinux.org/alpine/latest-stable/community
http://dl-cdn.alpinelinux.org/alpine/edge/main
http://dl-cdn.alpinelinux.org/alpine/edge/community
http://dl-cdn.alpinelinux.org/alpine/edge/testing
EOF

# upgrade all packages.
apk update
apk upgrade -U --available

# install the doas sudo shim.
apk add doas-sudo-shim bash curl xz

# add support for validating https certificates.
apk add ca-certificates openssl lsblk

# install the vagrant public key.
# NB vagrant will replace it on the first run.
install -d -m 700 /home/vagrant/.ssh
wget -qO /home/vagrant/.ssh/authorized_keys https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# install the Guest Additions.
if [ "$(cat /sys/devices/virtual/dmi/id/board_name)" == 'VirtualBox' ]; then
    # install the VirtualBox Guest Additions.
    apk add -U virtualbox-guest-additions
    rc-update add virtualbox-guest-additions
    echo vboxsf >>/etc/modules
#   modinfo vboxguest
else
    echo "Not a VirtualBox VM"
fi

# install vim.
apk add vim

#install nix
apk add nix

# disable the DNS reverse lookup on the SSH server. this stops it from
# trying to resolve the client IP address into a DNS domain name, which
# is kinda slow and does not normally work when running inside VB.
sed -i -E 's,#?(UseDNS\s+).+,\1no,' /etc/ssh/sshd_config

# use the up/down arrows to navigate the bash history.
# NB to get these codes, press ctrl+v then the key combination you want.
cat >>/etc/inputrc <<'EOF'
"\e[A": history-search-backward
"\e[B": history-search-forward
set show-all-if-ambiguous on
set completion-ignore-case on
EOF

# setup the shell profile.
cat >/etc/profile.d/login.sh <<'EOF'
export EDITOR=vim
export PAGER=less
alias l='ls -ahlF --color'
alias ll='l -a'
alias h='history 25'
alias j='jobs -l'
EOF

# zero the free disk space -- for better compression of the box file.
# NB prefer discard/trim (safer; faster) over creating a big zero filled file
#    (somewhat unsafe as it has to fill the entire disk, which might trigger
#    a disk (near) full alarm; slower; slightly better compression).
apk add util-linux
root_dev="$(findmnt -no SOURCE /)"
if [ "$(lsblk -no DISC-GRAN $root_dev | awk '{print $1}')" != '0B' ]; then
    while true; do
        output="$(fstrim -v /)"
        sync && sync && sync && blockdev --flushbufs $root_dev && sleep 15
        if [ "$output" == '/: 0 B (0 bytes) trimmed' ]; then
            break
        fi
    done
else
    dd if=/dev/zero of=/EMPTY bs=1M || true && sync && rm -f /EMPTY && sync
fi
