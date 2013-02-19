part sda 1 82 2048M 
part sda 2 83 +

format /dev/sda1 swap
format /dev/sda2 ext4

mountfs /dev/sda1 swap
mountfs /dev/sda2 ext4 / noatime

# retrieve latest autobuild stage version for stage_uri
[ "${arch}" == "x86" ]   && stage_latest $(uname -m)
[ "${arch}" == "amd64" ] && stage_latest amd64
tree_type   snapshot    http://distfiles.gentoo.org/snapshots/portage-latest.tar.bz2

# get kernel dotconfig from the official running kernel
cat /proc/config.gz | gzip -d > /dotconfig
# get rid of Gentoo official firmware .config..
grep -v CONFIG_EXTRA_FIRMWARE /dotconfig > /dotconfig2 ; mv /dotconfig2 /dotconfig
# ..and lzo compression
grep -v LZO /dotconfig > /dotconfig2 ; mv /dotconfig2 /dotconfig
kernel_config_file      /dotconfig
kernel_sources          gentoo-sources
genkernel_opts          --loglevel=5

timezone                UTC
rootpw                  a
bootloader              grub
keymap                  us # be-latin1 fr
hostname                gentoo
extra_packages          dhcpcd # syslog-ng vim openssh

#rcadd                   sshd       default
#rcadd                   syslog-ng  default
