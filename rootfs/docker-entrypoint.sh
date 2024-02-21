#!/bin/bash
TARGET_ADDR=${TARGET_ADDR:-1.1.1.1}
TARGET_ANALYSE_INTERVAL=${TARGET_ANALYSE_INTERVAL:-2}

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
	traceroute -q 3 -w 1 -m 15 --type icmp -I ${TARGET_ADDR} | while read line; do
		if [[ $line == *"traceroute to"* ]]; then
			echo "[$(_fdate)] $line"
		else
			echo -e "[$(_fdate)] \t$line"
		fi
	done
}

function ping_routine() {
	ping -n -c 5 -i 2 --ttl 2 -W 1 ${TARGET_ADDR} | while read pong; do
		if [[ $pong == "PING"* ]]; then
			echo -e "[$(_fdate)] $pong"
		elif [[ $pong == *"Request timeout"* ]]; then
			echo -e "[$(_fdate)] \t[!] $pong"
		elif [[ $pong == *"Time to live exceeded"* ]]; then
			echo -e "[$(_fdate)] \t[!] $pong (Possible reason: ICMP is disabled!)"
		elif [[ $pong == *"bytes from"* ]]; then
			echo -e "[$(_fdate)] \t[-] $pong"
		else
			echo -e "[$(_fdate)] \t$pong"
		fi
	done
}

function main() {
	echo "[$(_fdate)] Start network analysis on ${TARGET_ADDR}"
	echo "[$(_fdate)] "
	echo "[$(_fdate)] Service will start traceroute and ping routine and run every ${TARGET_ANALYSE_INTERVAL} seconds."
	echo "[$(_fdate)] Press Ctrl+C to stop."

	while true; do
		echo "[$(_fdate)] "; traceroute_routine
		sleep ${TARGET_ANALYSE_INTERVAL}

		for(( i=0; i<5; i++ )); do
			echo "[$(_fdate)] "; ping_routine
			sleep ${TARGET_ANALYSE_INTERVAL}
		done
	done
}

main "$@"
