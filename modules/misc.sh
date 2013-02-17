get_arch() {
    uname -m | sed -e 's:i[3-6]86:x86:' -e 's:x86_64:amd64:' -e 's:parisc:hppa:'
}

detect_disks() {
    if [ ! -d "/sys" ]; then
        error "Cannot detect disks due to missing /sys"
        exit 1
    fi
    count=0
    for i in /sys/block/[hs]d[a-z]; do
        if [ "$(< ${i}/removable)" = "0" ]; then
            eval "disk${count}=$(basename ${i})"
            count=$(expr ${count} + 1)
        fi
    done
}

get_mac_address() {
    ifconfig | grep HWaddr | head -n 1 | sed -e 's:^.*HWaddr ::' -e 's: .*$::'
}

# NOTE baselayout-1 & baselayout-2 config syntax is not compatible
# uppercase in baselayout-1 lower in -2
detect_baselayout2() {
    spawn_chroot "[ -e /lib/librc.so ]" 
}

# grub-0.9x & grub-1.9x config syntax is not compatible
detect_grub2() {
    # find installed grub version: 0 is version 1 and 1 is version
    # FIXME only works for gentoo/funtoo but not exherbo :(
    vgrub=$(cat ${chroot_dir}/var/db/pkg/sys-boot/grub*/PF | cut -d"-" -f2 | cut -d. -f1)
    if [ "$vgrub" == "1" ] || [ "$vgrub" == "2" ]; then
        bootloader=grub2
    else
        bootloader=grub
    fi
}
