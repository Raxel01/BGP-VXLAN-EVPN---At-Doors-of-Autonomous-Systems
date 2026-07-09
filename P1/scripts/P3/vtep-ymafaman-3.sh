#!/bin/sh

/usr/lib/frr/zebra -d -F traditional -A 127.0.0.1
/usr/lib/frr/bgpd -d -F traditional -A 127.0.0.1
/usr/lib/frr/ospfd -d -F traditional -A 127.0.0.1
/usr/lib/frr/isisd -d -F traditional -A 127.0.0.1

sleep 2

#############################################

vtysh	-c "configure terminal" \
	-c "router ospf" \
	-c "ospf router-id 4.4.4.4" \
	-c "network 4.4.4.4/32 area 0" \
	-c "network 10.0.14.0/30 area 0" \
	-c "end" \
	-c "write"

vtysh	-c "configure terminal" \
	-c "router bgp 3334" \
	-c "bgp router-id 4.4.4.4" \
	-c "neighbor 1.1.1.1 remote-as 3334" \
	-c "neighbor 1.1.1.1 update-source lo" \
	-c "address-family l2vpn evpn" \
	-c "neighbor 1.1.1.1 activate" \
	-c "advertise-all-vni" \
	-c "exit-address-family" \
	-c "end" \
	-c "write"
exec /bin/sh
