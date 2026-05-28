# Multicast VXLAN Verification

Use this guide after starting both routers in multicast mode:

```text
Alpine FRR Router 1: /usr/local/bin/start-vxlan.sh router1 multicast
Alpine FRR Router 2: /usr/local/bin/start-vxlan.sh router2 multicast
```

The host start commands remain:

```text
Alpine Host 1: /usr/local/bin/start-vxlan.sh host1
Alpine Host 2: /usr/local/bin/start-vxlan.sh host2
```

## Expected Configuration

```text
Router 1 underlay IP: 10.0.0.1/24
Router 2 underlay IP: 10.0.0.2/24
Host 1 IP:            192.168.1.1/24
Host 2 IP:            192.168.1.2/24
VNI:                  10
Multicast group:      239.1.1.1
VXLAN UDP port:       4789
```

## Verify The Underlay

On `Alpine FRR Router 1`:

```sh
ping 10.0.0.2
```

On `Alpine FRR Router 2`:

```sh
ping 10.0.0.1
```

Both pings must succeed before testing VXLAN.

## Verify The VXLAN

Run on each router:

```sh
ip -d link show vxlan10
bridge link
ip maddr show dev eth1
```

The `vxlan10` output should contain:

```text
id 10
group 239.1.1.1
dstport 4789
```

## Test Host Connectivity

On `Alpine Host 1`:

```sh
ping 192.168.1.2
```

The first ping may take a moment while ARP discovers Host 2.

## Capture Multicast VXLAN Traffic

On either router, capture traffic on the underlay interface:

```sh
tcpdump -ni eth1 'host 239.1.1.1 or udp port 4789'
```

While the capture is running, on `Alpine Host 1` force a new ARP exchange and
send traffic:

```sh
ip neigh flush dev eth0
ping 192.168.1.2
```

The ARP request is broadcast inside the VXLAN, so you should see traffic sent
to multicast group `239.1.1.1`. After the routers learn the host MAC
addresses, regular unicast packets may no longer use the multicast group.

## Troubleshooting

If `vxlan10` is missing on a router, check that its GNS3 start command includes
the `multicast` argument and that the router template runs in privileged mode.

If `ping 10.0.0.2` or `ping 10.0.0.1` fails, fix the underlay connection
before investigating VXLAN.
