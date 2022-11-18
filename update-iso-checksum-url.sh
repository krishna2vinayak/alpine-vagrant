#!/bin/bash
# this will update the alpine.json file with the current image checksum.
set -eux

ver=$(curl -fsSL https://alpinelinux.org/downloads/ | grep "Current Alpine Version" | grep -Eo "(\d+\.)+\d+")
iso_url="https://dl-cdn.alpinelinux.org/alpine/v${ver%??}/releases/x86_64/alpine-virt-${ver}-x86_64.iso"
iso_checksum=$(curl -o- --silent --show-error $iso_url.sha256 | awk '{print $1}')
/usr/local/bin/gsed -i -E "s,(\"iso_checksum\": \")[a-z0-9:]*?(\"),\\1sha256:$iso_checksum\\2,g" alpine.json
/usr/local/bin/gsed -i -E "s,(\"iso_url\": \")[a-z0-9:]*?(\"),\\1$iso_url\\2,g" alpine.json
echo 'iso_checksum | iso_url updated successfully'
