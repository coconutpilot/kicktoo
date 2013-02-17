KV="3.4.31"

part sda 1 83 100M
part sda 2 83 +

format /dev/sda1 ext2
format /dev/sda2 ext4

mountfs /dev/sda1 ext2 /boot
mountfs /dev/sda2 ext4 / noatime

# don't compile kernel
kernel_binary $(pwd)/kbin/kernel-genkernel-${arch}-3.2.1-gentoo-r2
initramfs_binary $(pwd)/kbin/initramfs-genkernel-${arch}-3.2.1-gentoo-r2
systemmap_binary $(pwd)/kbin/System.map-genkernel-${arch}-3.2.1-gentoo-r2

stage_uri http://dev.exherbo.org/stages/exherbo-x86-current.tar.xz
rootpw    a
bootloader grub

pre_setup_fstab(){
    spawn_chroot "cave sync"                                           || die "could not sync exheres tree"
    spawn_chroot "cave fix-cache"                                      || die "could not sync exheres tree"

    spawn_chroot "echo \"*/* systemd\" >> /etc/paludis/options.conf"   || die "could not copy systemd config"
    spawn_chroot "cave resolve systemd -x"                             || die "could not install systemd"
    spawn_chroot "eclectic init set systemd"                           || die "could not init set systemd"
#    spawn_chroot "cave resolve world -x"                               || warn "could not update world"

    spawn_chroot "echo exherbo > /etc/hostname"                                                                         || die "could not create /etc/hostname"
    for p in ${extra_packages}; do
        spawn_chroot "cave resolve -x ${p}"                                                                             || die "could not install extra packages"
    done
}
skip install_kernel_builder
skip install_initramfs_builder
skip build_kernel
skip setup_host
skip setup_keymap
skip install_bootloader
skip configure_bootloader
post_configure_bootloader() {
    spawn_chroot "grub-install --force /dev/sda" || die "Could not install grub to /boot/grub"
    spawn_chroot "echo \"127.0.0.1 localhost exherbo\n::1 localhost\n\" > /etc/hosts"

    spawn_chroot "echo \"set timeout=10\nset default=0\nmenuentry Exherbo {\n  set root=(hd0,1)\n  linux /kernel-genkernel-${arch}-3.2.1-gentoo-r2 root=/dev/sda2\n  initrd /initramfs-genkernel-${arch}-3.2.1-gentoo-r2\n}\" >  /boot/grub/grub.cfg"
}
