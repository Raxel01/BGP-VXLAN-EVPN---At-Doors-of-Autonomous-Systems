#!/bin/sh

/usr/lib/frr/zebra -d -F traditional -A 127.0.0.1
/usr/lib/frr/bgpd -d -F traditional -A 127.0.0.1
/usr/lib/frr/ospfd -d -F traditional -A 127.0.0.1
/usr/lib/frr/isisd -d -F traditional -A 127.0.0.1

sleep 2

#############################################

vtysh	-c "configure terminal" \
	-c "router ospf" \
	-c "ospf router-id 1.1.1.1" \
	-c "network 1.1.1.1/32 area 0" \
	-c "network 10.0.12.0/30 area 0" \
	-c "network 10.0.13.0/30 area 0" \
	-c "network 10.0.14.0/30 area 0" \
	-c "end" \
	-c "write" 

vtysh	-c "configure terminal" \
	-c "router bgp 3334" \
	-c "bgp router-id 1.1.1.1" \
	-c "neighbor 2.2.2.2 remote-as 3334" \
	-c "neighbor 2.2.2.2 update-source lo" \
	-c "neighbor 3.3.3.3 remote-as 3334" \
	-c "neighbor 3.3.3.3 update-source lo" \
	-c "neighbor 4.4.4.4 remote-as 3334" \
	-c "neighbor 4.4.4.4 update-source lo" \
	-c "address-family l2vpn evpn" \
	-c "neighbor 2.2.2.2 activate" \
	-c "neighbor 2.2.2.2 route-reflector-client" \
	-c "neighbor 3.3.3.3 activate" \
	-c "neighbor 3.3.3.3 route-reflector-client" \
	-c "neighbor 4.4.4.4 activate" \
	-c "neighbor 4.4.4.4 route-reflector-client" \
	-c "exit-address-family" \
	-c "end" \
	-c "write"
exec /bin/sh
