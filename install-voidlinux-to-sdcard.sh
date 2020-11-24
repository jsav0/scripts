#!/bin/sh
# n0
# Description: partition, format, and install void linux onto a memory card
# Date: 20201124 
# a110w

target=/dev/mmcblk0
src=https://alpha.de.repo.voidlinux.org/live/current/void-rpi3-musl-PLATFORMFS-20191109.tar.xz

create_partitions(){
	[ -z $target ] && echo "You must provide the target memory card to partition. " && exit 1
	parted --script "$target" \
	mktable msdos \
	mkpart primary fat32 2048s 256MB \
	toggle 1 boot \
	mkpart primary ext4 256MB 100%
}

create_filesystems(){
	mkfs.vfat "$target"p1
	mkfs.ext4 -O '^has_journal' "$target"p2
}

mount_filesystems(){
	mkdir -p /mnt/rpi/rootfs
	mount "$target"p2 /mnt/rpi/rootfs
	mkdir /mnt/rpi/rootfs/boot
	mount "$target"p1 /mnt/rpi/rootfs/boot
}

extract_voidfs(){
	wget "$src" -qO - | tar xvfJp - -C /mnt/rpi/rootfs
	echo '/dev/mmcblk0p1 /boot vfat defaults 0 0' >> /mnt/rpi/rootfs/etc/fstab
}

unmount_filesystems(){
	umount /mnt/rpi/rootfs/boot && \
	umount /mnt/rpi/rootfs
}

create_partitions && \
create_filesystems && \
mount_filesystems && \
extract_voidfs && \
unmount_filesystems
