gptpart sda 1 8300 100M
gptpart sda 2 ef02 32M # for GPT/GUID only
gptpart sda 3 8200 2048M
gptpart sda 4 8300 +

format /dev/sda1 ext2
format /dev/sda3 swap
format /dev/sda4 ext4

mountfs /dev/sda1 ext2 /boot
mountfs /dev/sda3 swap
mountfs /dev/sda4 ext4 / noatime

[ "${arch}" == "x86" ]   && stage_uri http://ftp.osuosl.org/pub/funtoo/funtoo-stable/x86-32bit/$(uname -m)/stage3-latest.tar.xz
[ "${arch}" == "amd64" ] && stage_uri http://ftp.osuosl.org/pub/funtoo/funtoo-stable/x86-64bit/generic_64/stage3-latest.tar.xz
tree_type   snapshot    http://ftp.osuosl.org/pub/funtoo/funtoo-stable/snapshots/portage-latest.tar.xz

## get kernel dotconfig from running kernel
#cat /proc/config.gz | gzip -d > /dotconfig
## get rid of Gentoo official firmware .config..
#grep -v CONFIG_EXTRA_FIRMWARE /dotconfig > /dotconfig2 ; mv /dotconfig2 /dotconfig
## ..and lzo compression
#grep -v LZO /dotconfig > /dotconfig2 ; mv /dotconfig2 /dotconfig
#kernel_config_file      /dotconfig
#kernel_sources          gentoo-sources
#genkernel_opts          --loglevel=5

# ship the binary kernel instead of compiling (faster)
kernel_binary $(pwd)/kbin/kernel-genkernel-${arch}-3.2.1-gentoo-r2
initramfs_binary $(pwd)/kbin/initramfs-genkernel-${arch}-3.2.1-gentoo-r2
systemmap_binary $(pwd)/kbin/System.map-genkernel-${arch}-3.2.1-gentoo-r2

timezone		UTC
rootpw 			a
bootloader 		grub
keymap			fr # be-latin1 en
hostname		funtoo
#extra_packages         vixie-cron syslog-ng openssh
#rcadd			vixie-cron default
#rcadd			syslog-ng default
#rcadd			sshd default

#############################################################################
# 1. commented skip runsteps are actually running!                          #
# 2. put your custom code if any in pre_ or post_ functions                 #
#############################################################################

# pre_partition() {
# }
# skip partition
# post_partition() {
# }

# pre_setup_mdraid() {
# }
# skip setup_mdraid
# post_setup_mdraid() {
# }

# pre_setup_lvm() {
# }
# skip setup_lvm
# post_setup_lvm() {
# }

# pre_luks_devices() {
# }
# skip luks_devices
# post_luks_devices() {
# }

# pre_format_devices() {
# }
# skip format_devices
# post_format_devices() {
# }

# pre_mount_local_partitions() {
# }
# skip mount_local_partitions
# post_mount_local_partitions() {
# }

# pre_mount_network_shares() {
# }
# skip mount_network_shares
# post_mount_network_shares() {
# }

# pre_fetch_stage_tarball() {
# }
# skip fetch_stage_tarball
# post_fetch_stage_tarball() {
# }

# pre_unpack_stage_tarball() {
# }
# skip unpack_stage_tarball
# post_unpack_stage_tarball() {
# }

# pre_prepare_chroot() {
# }
# skip prepare_chroot
# post_prepare_chroot() { 
# }

# pre_setup_fstab() {
# }
# skip setup_fstab
# post_setup_fstab() { 
# }

# pre_fetch_repo_tree() {
# }
# skip fetch_repo_tree
# post_fetch_repo_tree() {
# }

# pre_unpack_repo_tree() {
# }
# skip unpack_repo_tree
post_unpack_repo_tree() {
    # git style Funtoo portage
    spawn_chroot "cd /usr/portage && git checkout funtoo.org" || die "could not checkout funtoo git repo"
}

# pre_copy_kernel() {
# }
# skip copy_kernel
# post_copy_kernel() {
# }

# pre_install_kernel_builder() {
# }
# skip install_kernel_builder
# post_install_kernel_builder() {
# }

# pre_install_initramfs_builder() {
# }
# skip install_initramfs_builder
# post_install_initramfs_builder() {
# }

# pre_build_kernel() {
# }
# skip build_kernel
# post_build_kernel() {
# }

# pre_build_initramfs() {
# }
# skip build_initramfs
# post_build_initramfs() {
# }

# pre_setup_network_post() {
# }
# skip setup_network_post
# post_setup_network_post() {
# }

# pre_setup_root_password() {
# }
# skip setup_root_password
# post_setup_root_password() {
# }

# pre_setup_timezone() {
# }
# skip setup_timezone
# post_setup_timezone() {
# }

# pre_setup_keymap() {
# }
# skip setup_keymap
# post_setup_keymap() {
# }

# pre_setup_host() {
# }
# skip setup_host
# post_setup_host() {
# }

# pre_install_bootloader() {
# }
# skip install_bootloader
post_install_bootloader() {
    # $(echo ${device} | cut -c1-8) is like /dev/sdx
    spawn_chroot "grub-install $(echo ${device} | cut -c1-8)" || die "cannot grub-install $(echo ${device} | cut -c1-8)"
    spawn_chroot "boot-update"                                || die "boot-update failed"
}

# pre_configure_bootloader() {
# }
skip configure_bootloader
# post_configure_bootloader() {
# }

# pre_install_extra_packages() {
# }
# skip install_extra_packages
# post_install_extra_packages() {
# }

# pre_add_and_remove_services() {
# }
# skip add_and_remove_services
# post_add_and_remove_services() {
# }

# pre_run_post_install_script() { 
# }
# skip run_post_install_script
# post_run_post_install_script() {
# }
