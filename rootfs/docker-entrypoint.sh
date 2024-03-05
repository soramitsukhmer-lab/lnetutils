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

function ping_routine() {
	ping -n -i ${TARGET_CHECK_INTERVAL} --ttl ${TARGET_CHECK_MAX_HOP} -W 1 ${TARGET_HOST} | ping_routine_pipeline
}

function ping_routine_pipeline() {
	local prev_icmp_seq=0
	local expected_icmp_seq=0
	local missing_icmp_seq_count=0

	while read line; do
		if [[ $line == *"PING"* ]]; then
			continue
		fi
		_time=$(echo $line | grep -o "time=[0-9.]* ms" | cut -d= -f2)
		_ttl=$(echo $line | grep -o "ttl=[0-9]*" | cut -d= -f2)
		_icmp_seq=$(echo $line | grep -o "icmp_seq=[0-9]*" | cut -d= -f2)
		echo -n "time=\"$(_fdate)\""
		echo -n " icmp_seq=$_icmp_seq"
		# echo -n " ttl=\"$_ttl\""
		echo -n " latency=\"$_time\""
		echo -n " msg=\"$line\""
		echo -n " prev_icmp_seq=$prev_icmp_seq"
		if [[ $_icmp_seq -eq 1 ]]; then
			prev_icmp_seq=$_icmp_seq
			expected_icmp_seq=$_icmp_seq
		elif [[ $_icmp_seq -gt $prev_icmp_seq ]]; then
			prev_icmp_seq=$_icmp_seq
		fi
		if [[ $_icmp_seq -ne $expected_icmp_seq ]]; then
			missing_icmp_seq_count=$(($_icmp_seq-$expected_icmp_seq))
		fi
		expected_icmp_seq=$((prev_icmp_seq+1))
		echo -n " expected_icmp_seq=$expected_icmp_seq"
		if [[ $missing_icmp_seq_count -ne 0 ]]; then
			echo -n " err=\"At least $missing_icmp_seq_count icmp_seq(s) failed to reply!\""
			missing_icmp_seq_count=0
		else
			echo -n " err=\"\""
		fi
		echo ""
	done

}

function main() {
	echo "time=\"$(_fdate)\" msg=\"Start network analysis on ${TARGET_HOST}\""
	echo "time=\"$(_fdate)\" msg=\"Press Ctrl+C to stop.\""

	while true; do
		ping_routine
		sleep ${TARGET_CHECK_INTERVAL}
	done
}

main "$@"
