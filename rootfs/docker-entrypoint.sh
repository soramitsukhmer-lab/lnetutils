#!/bin/bash
INSPECT_TARGET_ADDR=${INSPECT_TARGET_ADDR:-1.1.1.1}
PING_WAIT_SEC=${PING_WAIT_SEC:-2}
PINT_TIMEOUT=${PINT_TIMEOUT:-60}

trap 'exit 0' SIGTERM
trap 'exit 0' SIGINT

exec 3>&1

function _fdate() {
    echo -n $(date +%Y-%m-%d\ %H:%M:%S)
}

function _ping_stdout() {
    while read pong; do
        if [[ $pong == "PING"* ]]; then
            echo "[$(_fdate)] $pong"
        elif [[ $pong == *"Request timeout"* ]]; then
            echo -e "[$(_fdate)]\t[!] $pong"
        else
            echo -e "[$(_fdate)]\t[-] $pong"
        fi
    done
}
function _traceroute_stdout() {
    while read pong; do
        echo -e "[$(_fdate)]\t$pong"
    done
}

function main() {
    while true; do
        echo -n "[$(_fdate)] "; traceroute -nvIS -z ${PING_WAIT_SEC} ${INSPECT_TARGET_ADDR} | _traceroute_stdout
        sleep ${PING_WAIT_SEC}
        ping -n -t ${PINT_TIMEOUT} -i ${PING_WAIT_SEC} ${INSPECT_TARGET_ADDR} | _ping_stdout
        echo "[$(_fdate)]";
        sleep ${PING_WAIT_SEC}
    done
}

main "$@"
