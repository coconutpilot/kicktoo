part sda 1 83 100M  # /boot
part sda 2 83 +     # /

luks bootpw    a    # CHANGE ME
luks /dev/sda2 root aes sha256

format /dev/sda1        ext2
format /dev/mapper/root ext4

mountfs /dev/sda1        ext2 /boot
mountfs /dev/mapper/root ext4 / noatime

# retrieve latest autobuild stage version for stage_uri
[ "${arch}" == "x86" ]   && stage_latest $(uname -m)
[ "${arch}" == "amd64" ] && stage_latest amd64
tree_type   snapshot    http://distfiles.gentoo.org/snapshots/portage-latest.tar.bz2

# ship the binary kernel instead of compiling (faster)
kernel_binary           $(pwd)/kbin/luks/kernel-genkernel-${arch}-3.5.7-gentoo
initramfs_binary        $(pwd)/kbin/luks/initramfs-genkernel-${arch}-3.5.7-gentoo
systemmap_binary        $(pwd)/kbin/luks/System.map-genkernel-${arch}-3.5.7-gentoo

timezone                UTC
bootloader              grub
bootloader_kernel_args  crypt_root=/dev/sda2 # should match root device in the $luks variable
rootpw                  a
keymap                  fr # be-latin1 us
hostname                gentoo-luks
#extra_packages         openssh syslog-ng

#rcadd                  sshd default
#rcadd                  syslog-ng default
#rcadd                  vixie-cron default

pre_build_kernel() {
    spawn_chroot "emerge cryptsetup --autounmask-write" || die "could not autounmask cryptsetup"
    spawn_chroot "etc-update --automode -5" || die "could not etc-update --automode -5"
    spawn_chroot "emerge cryptsetup" || die "could not emerge cryptsetup"
}
