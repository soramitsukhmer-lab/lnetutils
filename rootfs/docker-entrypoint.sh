#!/bin/bash
INSPECT_TARGET_ADDR=${INSPECT_TARGET_ADDR:-1.1.1.1}
PING_WAIT_SEC=${PING_WAIT_SEC:-2}
PINT_TIMEOUT=${PINT_TIMEOUT:-60}

trap 'exit 0' SIGTERM
trap 'exit 0' SIGINT

exec 3>&1

export TRACEROUTE_ADDRESS_POOL=()

function _fdate() {
    echo -n $(date +%Y-%m-%d\ %H:%M:%S)
}

function _add_ip_to_pool() {
    local ip=$2
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        if [[ ! " ${TRACEROUTE_ADDRESS_POOL[@]} " =~ " ${ip} " ]]; then
            TRACEROUTE_ADDRESS_POOL+=($ip)
            echo "${TRACEROUTE_ADDRESS_POOL[@]}"
        fi
    fi
}

function traceroute_routine() {
    traceroute -nIS -z ${PING_WAIT_SEC} ${INSPECT_TARGET_ADDR} | while read line; do
        echo -e "[$(_fdate)]\t$line"
    done
}

function ping_routine() {
    ping -n -t ${PINT_TIMEOUT} -i ${PING_WAIT_SEC} ${INSPECT_TARGET_ADDR} | while read pong; do
        if [[ $pong == "PING"* ]]; then
            echo "[$(_fdate)] $pong"
        elif [[ $pong == *"Request timeout"* ]]; then
            echo -e "[$(_fdate)]\t[!] $pong"
        elif [[ $pong == *"bytes from"* ]]; then
            echo -e "[$(_fdate)]\t[-] $pong"
        else
            echo -e "[$(_fdate)] $pong"
        fi
    done
}

function main() {
    echo "[$(_fdate)] Start network analysis on ${INSPECT_TARGET_ADDR}"
    echo "[$(_fdate)] "
    echo "[$(_fdate)] Service will start traceroute and ping routine and run every ${PING_WAIT_SEC} seconds."
    echo "[$(_fdate)] Press Ctrl+C to stop."
    echo "[$(_fdate)] "
    while true; do
        echo -n "[$(_fdate)] "; traceroute_routine
        sleep ${PING_WAIT_SEC}
        echo "[$(_fdate)] "; ping_routine
        echo "[$(_fdate)] "; sleep ${PING_WAIT_SEC}
    done
}

main "$@"
