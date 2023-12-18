#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "This script must run as root."
  exit
fi

ARCH=$(uname -m)
VARIANT="cinnamon"
PKGS="firefox cups cups-filters system-config-printer vim-huge keepassxc gufw git btop avahi nss-mdns python3-numpy lazygit" 
SERV="cupsd avahi-daemon"
DATE=$(date -u +%Y%m%d_%H%M)

./build-x86-images.sh -d "${DATE}" -b "${VARIANT}" -- -p "${PKGS}" -S "${SERV}" -I ./includedir/

mount /dev/nvme0n1p2 /mnt
cp "void-live-${ARCH}-${DATE}-${VARIANT}.iso" "/mnt/@iso/"
umount /mnt

./populateGRUB.sh
