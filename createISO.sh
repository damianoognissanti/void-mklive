ARCH=$(uname -m)
VARIANT="cinnamon"
PKGS="firefox cups cups-filters system-config-printer vim-huge keepassxc gufw git btop avahi nss-mdns python3-numpy" 
SERV="cupsd avahi-daemon"
DATE=$(date -u +%Y%m%d)

cat << EOT >> ./includedir/etc/grub.d/40_custom
menuentry "VoidISO ${DATE} ${VARIANT}" --class VoidLinux {
    insmod btrfs
    set iso_file="/@iso/void-live-${ARCH}-${DATE}-${VARIANT}.iso"
EOT
cat << 'HERE' >> ./includedir/etc/grub.d/40_custom
    search --set=iso_partition --no-floppy --file $iso_file
    probe --set=iso_partition_uuid --fs-uuid $iso_partition
    set img_dev="/dev/disk/by-uuid/$iso_partition_uuid"
    loopback loop ($iso_partition)$iso_file
    set boot_option=""
    linux (loop)/boot/vmlinuz iso-scan/filename=$iso_file root=live:CDLABEL=VOID_LIVE ro init=/sbin/init $boot_option
    initrd (loop)/boot/initrd
}
HERE

cp ./includedir/etc/grub.d/40_custom /etc/grub.d/40_custom
update-grub

./build-x86-images.sh -b "${VARIANT}" -- -k sv-latin1 -p "${PKGS}" -S "${SERV}" -I ./includedir/

mount /dev/nvme0n1p2 /mnt
cp "void-live-${ARCH}-${DATE}-${VARIANT}.iso" "/mnt/@iso/"
umount /mnt
