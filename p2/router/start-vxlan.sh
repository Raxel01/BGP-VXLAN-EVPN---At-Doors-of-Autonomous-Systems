#!/bin/sh

set -eu

open_shell_on_error()
{
	status=$?

	if [ "$status" -ne 0 ]; then
		echo "VXLAN startup failed with exit status $status." >&2
		echo "Check privileged mode and that eth0/eth1 exist, then rerun this script." >&2
		exec /bin/bash -i
	fi
}

trap open_shell_on_error EXIT

ROLE="${1:-${VXLAN_ROLE:-}}"
MODE="${2:-${VXLAN_MODE:-unicast}}"
ACCESS_IF="${ACCESS_IF:-eth0}"
UNDERLAY_IF="${UNDERLAY_IF:-eth1}"
BRIDGE="${BRIDGE:-br0}"
VXLAN_IF="${VXLAN_IF:-vxlan10}"
VNI="${VNI:-10}"
VXLAN_PORT="${VXLAN_PORT:-4789}"
MULTICAST_GROUP="${MULTICAST_GROUP:-239.1.1.1}"

case "$ROLE" in
	router1)
		LOCAL_IP="10.0.0.1"
		REMOTE_IP="10.0.0.2"
		;;
	router2)
		LOCAL_IP="10.0.0.2"
		REMOTE_IP="10.0.0.1"
		;;
	*)
		echo "usage: $0 {router1|router2} [unicast|multicast]" >&2
		exit 1
		;;
esac

case "$MODE" in
	unicast|multicast)
		;;
	*)
		echo "mode must be unicast or multicast" >&2
		exit 1
		;;
esac

ip link set "$UNDERLAY_IF" up
ip addr replace "$LOCAL_IP/24" dev "$UNDERLAY_IF"
ip link set "$ACCESS_IF" up

if ! ip link show "$BRIDGE" >/dev/null 2>&1; then
	ip link add "$BRIDGE" type bridge
fi
ip link set "$BRIDGE" up
ip link set "$ACCESS_IF" master "$BRIDGE"

# Recreate the tunnel so switching between unicast and multicast is reliable.
if ip link show "$VXLAN_IF" >/dev/null 2>&1; then
	ip link set "$VXLAN_IF" down
	ip link del "$VXLAN_IF"
fi

if [ "$MODE" = "multicast" ]; then
	ip route replace 239.0.0.0/8 dev "$UNDERLAY_IF" src "$LOCAL_IP"
	ip link add "$VXLAN_IF" type vxlan \
		id "$VNI" \
		local "$LOCAL_IP" \
		group "$MULTICAST_GROUP" \
		dstport "$VXLAN_PORT" \
		dev "$UNDERLAY_IF"
else
	ip route del 239.0.0.0/8 dev "$UNDERLAY_IF" 2>/dev/null || true
	ip link add "$VXLAN_IF" type vxlan \
		id "$VNI" \
		local "$LOCAL_IP" \
		remote "$REMOTE_IP" \
		dstport "$VXLAN_PORT" \
		dev "$UNDERLAY_IF"
fi

ip link set "$VXLAN_IF" master "$BRIDGE"
ip link set "$VXLAN_IF" up

echo "$ROLE configured: $MODE VXLAN VNI $VNI on $LOCAL_IP"
trap - EXIT
exec /bin/bash -i
