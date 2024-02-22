#!/bin/bash
TARGET_HOST=${TARGET_HOST:-1.1.1.1}
TARGET_PORT=${TARGET_PORT:-80}
TARGET_CHECK_INTERVAL=${TARGET_CHECK_INTERVAL:-2}
TARGET_CHECK_MAX_HOP=${TARGET_CHECK_MAX_HOP:-15}

trap 'exit 0' SIGTERM
trap 'exit 0' SIGINT

exec 2>&1

function _fdate() {
	echo -n $(date +%Y-%m-%d\ %H:%M:%S)
}

function traceroute_routine() {
	traceroute -q 3 -w ${TARGET_CHECK_INTERVAL} -m ${TARGET_CHECK_MAX_HOP} --type icmp -I ${TARGET_HOST} | while read line; do
		if [[ $line == *"traceroute to"* ]]; then
			echo "[$(_fdate)] $line"
		else
			echo -e "[$(_fdate)] \t$line"
		fi
	done
}

function ping_routine() {
	ping -n -c 5 -i ${TARGET_CHECK_INTERVAL} --ttl ${TARGET_CHECK_MAX_HOP} -W 1 ${TARGET_HOST} | while read pong; do
		if [[ $pong == "PING"* ]]; then
			echo -e "[$(_fdate)] $pong"
		elif [[ $pong == *"Request timeout"* ]]; then
			echo -e "[$(_fdate)] \t[!] $pong"
		elif [[ $pong == *"Time to live exceeded"* ]]; then
			echo -e "[$(_fdate)] \t[!] $pong (reason: ICMP might be disabled!)"
		elif [[ $pong == *"bytes from"* ]]; then
			echo -e "[$(_fdate)] \t[-] $pong"
		else
			echo -e "[$(_fdate)] \t$pong"
		fi
	done
}

function main() {
	echo "[$(_fdate)] Start network analysis on ${TARGET_HOST}"
	echo "[$(_fdate)] "
	echo "[$(_fdate)] Service will start traceroute once every 5 ping routines executed"
	echo "[$(_fdate)] and re-run every ${TARGET_CHECK_INTERVAL} seconds."
	echo "[$(_fdate)] "
	echo "[$(_fdate)] Customizing the following environment variables to change the behavior:"
	echo "[$(_fdate)] - TARGET_HOST=${TARGET_HOST}"
	echo "[$(_fdate)] - TARGET_CHECK_INTERVAL=${TARGET_CHECK_INTERVAL} (default: 2)"
	echo "[$(_fdate)] - TARGET_CHECK_MAX_HOP=${TARGET_CHECK_MAX_HOP} (default: 15)"
	echo "[$(_fdate)] "
	echo "[$(_fdate)] Press Ctrl+C to stop."

	while true; do
		echo "[$(_fdate)] "; traceroute_routine
		sleep ${TARGET_CHECK_INTERVAL}

		for(( i=0; i<5; i++ )); do
			echo "[$(_fdate)] "; ping_routine
			sleep ${TARGET_CHECK_INTERVAL}
		done
	done
}

main "$@"
