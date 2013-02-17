isafunc() {
    local func=$1

    declare -f ${func} > /dev/null
    local exitcode=$?
#    debug isafunc "${func} with exitcode $exitcode"
    return $exitcode
}

runstep() {
    local func=$1
    local descr=$2
    local skipfunc=$(eval $(echo echo "\${skip_${func}}"))

    if [ "${skipfunc}" != "1" ]; then
        if [ -n "${server}" ]; then
            server_send_request "update_status" "func=${func}&descr=$(echo "${descr}" | sed -e 's: :+:g')"
        fi
    fi

    if $(isafunc pre_${func}); then
        echo -e "  >>> pre_${func}()"
        debug runstep "executing pre-hook for ${func}"
        pre_${func}
    fi

    if [ "${skipfunc}" != "1" ]; then
        notify "${descr}"

        ${func} # <<<

    else
        debug runstep "skipping step ${func}"
    fi

    if $(isafunc post_${func}); then
        echo -e "  >>> post_${func}()"
        debug runstep "executing post-hook for ${func}"
        post_${func}
    fi
}
