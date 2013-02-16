KV="3.4.31"

part sda 1 83 100M
part sda 2 83 +

format /dev/sda1 ext2
format /dev/sda2 ext4

mountfs /dev/sda1 ext2 /boot
mountfs /dev/sda2 ext4 / noatime

stage_uri  http://dev.exherbo.org/stages/exherbo-x86-current.tar.xz
rootpw     a

pre_setup_fstab(){
    # rewrite install_repo_tree
#    spawn_chroot "cave sync"                        || die "could not sync exheres tree"
#    spawn_chroot "cave resolve world -cx"           || warn "could not update world"
#    spawn_chroot "cave resolve -x sys-apps/systemd" || die "could not install systemd"
    fetch "http://www.kernel.org/pub/linux/kernel/v3.x/linux-${KV}.tar.bz2" "${chroot_dir}/usr/src/linux-${KV}.tar.bz2" || die "could not fetch kernel source"
    spawn_chroot "tar xfj /usr/src/linux-${KV}.tar.bz2 -C /usr/src/"                                                    || die "could not untar kernel tarball"
    spawn_chroot "ln -sf /usr/src/linux-${KV} /usr/src/linux"                                                           || die "could not symlink source"
    # get kernel dotconfig from running kernel
    cat /proc/config.gz | gzip -d > ${chroot_dir}/usr/src/linux/.config
    spawn_chroot "cd /usr/src/linux && yes '' |  make -s oldconfig && make && make modules_install"                     || die "could not build the kernel"
    spawn_chroot "mount /boot"
    spawn_chroot "cp /usr/src/linux/arch/${arch}/boot/bzImage /boot/kernel-genkernel-${arch}-${KV}"                     || die "could not copy the kernel"
    echo exherbo > /etc/hostname
    for p in ${extra_packages}; do
        spawn_chroot "cave resolve ${p}" || die "could not install extra packages"
    done
}
skip install_kernel_builder
skip install_initramfs_builder
skip build_kernel
skip setup_host
skip setup_keymap
skip install_bootloader
skip configure_bootloader
skip install_extra_packages
