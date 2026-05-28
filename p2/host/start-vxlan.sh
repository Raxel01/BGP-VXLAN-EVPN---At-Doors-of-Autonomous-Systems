#!/bin/sh

set -eu

open_shell_on_error()
{
	status=$?

	if [ "$status" -ne 0 ]; then
		echo "Host startup failed with exit status $status." >&2
		echo "Check that eth0 exists, then rerun this script." >&2
		exec /bin/sh -i
	fi
}

trap open_shell_on_error EXIT

ROLE="${1:-${VXLAN_ROLE:-}}"
ACCESS_IF="${ACCESS_IF:-eth0}"

case "$ROLE" in
	host1)
		HOST_IP="192.168.1.1"
		;;
	host2)
		HOST_IP="192.168.1.2"
		;;
	*)
		echo "usage: $0 {host1|host2}" >&2
		exit 1
		;;
esac

ip link set "$ACCESS_IF" up
ip addr replace "$HOST_IP/24" dev "$ACCESS_IF"

echo "$ROLE configured: $HOST_IP/24 on $ACCESS_IF"
trap - EXIT
exec /bin/sh -i
