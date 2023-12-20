#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "This script must run as root."
  exit
fi

mount /dev/nvme0n1p2 /mnt
rm /etc/grub.d/20_custom
touch /etc/grub.d/20_custom
cat << 'HERE' >> /etc/grub.d/20_custom
#!/bin/sh
exec tail -n +3 $0
HERE

files=(/mnt/\@iso/*.iso)
for ((i=${#files[@]}-1; i>=0; i--)); do
base="${files[i]##*/}"
cat << EOT >> /etc/grub.d/20_custom
menuentry "${base}" --class VoidLinux {
    insmod btrfs
    set iso_file="/@iso/${base}"
EOT
cat << 'HERE' >> /etc/grub.d/20_custom
    search --set=iso_partition --no-floppy --file $iso_file
    probe --set=iso_partition_uuid --fs-uuid $iso_partition
    set img_dev="/dev/disk/by-uuid/$iso_partition_uuid"
    loopback loop ($iso_partition)$iso_file
    set boot_option=""
    linux (loop)/boot/vmlinuz iso-scan/filename=$iso_file root=live:CDLABEL=VOID_LIVE ro init=/sbin/init $boot_option
    initrd (loop)/boot/initrd
}
HERE

done

umount /mnt
chmod +x /etc/grub.d/20_custom 
update-grub
