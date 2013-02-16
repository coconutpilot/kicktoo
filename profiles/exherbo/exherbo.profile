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
    spawn_chroot "cave sync"                                                                                            || die "could not sync exheres tree"
    spawn_chroot "cave fix-cache"                                                                                       || die "could not sync exheres tree"

    spawn_chroot "echo \"*/* systemd\" >> /etc/paludis/options.conf"                                                    || die "could not copy systemd config"
    spawn_chroot "cave resolve world -x"                                                                                || warn "could not update world"
    spawn_chroot "cave resolve -x systemd"                                                                              || die "could not install systemd"

    # compile kernel
#    fetch "http://www.kernel.org/pub/linux/kernel/v3.x/linux-${KV}.tar.bz2" "${chroot_dir}/usr/src/linux-${KV}.tar.bz2" || die "could not fetch kernel source"
#    spawn_chroot "tar xfj /usr/src/linux-${KV}.tar.bz2 -C /usr/src/"                                                    || die "could not untar kernel tarball"
#    spawn_chroot "ln -sf /usr/src/linux-${KV} /usr/src/linux"                                                           || die "could not symlink source"
#    spawn_chroot "cat /proc/config.gz | gzip -d | grep -v CONFIG_EXTRA_FIRMWARE | grep -v LZO > /usr/src/linux/.config" || die "could not copy kernel config"
#    spawn_chroot "cd /usr/src/linux && yes '' |  make -s oldconfig && make && make modules_install"                     || die "could not build the kernel"
#    spawn_chroot "mount /dev/sda1 /boot"
#    spawn_chroot "cp /usr/src/linux/arch/${arch}/boot/bzImage /boot/kernel-genkernel-${arch}-${KV}"                     || die "could not copy the kernel"

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
    spawn_chroot "echo \"set timeout=10\nset default=0\nmenuentry Exherbo {\n  set root=(hd0,1)\n  linux /kernel-genkernel-${arch}-3.2.1-gentoo-r2 root=/dev/sda2\n  initramfs /initramfs-genkernel-${arch}-3.2.1-gentoo-r2\n}\" >  /boot/grub/grub.cfg"
#    spawn_chroot "echo \"set timeout=10\nset default=0\nmenuentry Exherbo {\n  set root=(hd0,1)\n  linux /kernel-genkernel-${arch}-${KV}" root=/dev/sda2\n}\" >  /boot/grub/grub.cfg"
}