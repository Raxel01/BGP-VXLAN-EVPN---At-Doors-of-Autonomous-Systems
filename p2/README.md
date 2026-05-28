# VXLAN Lab Usage

This project provides reusable Alpine container images and startup scripts for
a GNS3 VXLAN lab. The scripts make the network configuration persistent across
container restarts.

## Build The Images

From this directory:

```sh
docker build -t alpine-frr router
docker build -t alpine-host host
```

After rebuilding an image, remove any older instance of that Docker node from
the GNS3 topology and add a fresh node from its template. An already-created
container does not receive files from a newly rebuilt image.

## GNS3 Topology

Create this topology:

```text
Alpine Host 1 eth0 <-> Alpine FRR Router 1 eth0
Alpine FRR Router 1 eth1 <-> Ethernet switch <-> eth1 Alpine FRR Router 2
Alpine FRR Router 2 eth0 <-> Alpine Host 2 eth0
```

The router nodes require at least two adapters and must run in privileged
mode. The host nodes require one adapter.

## Unicast VXLAN

Create four GNS3 Docker templates from the two images, one template per node
role, with these start commands:

```text
Alpine FRR Router 1: /usr/local/bin/start-vxlan.sh router1
Alpine FRR Router 2: /usr/local/bin/start-vxlan.sh router2
Alpine Host 1:       /usr/local/bin/start-vxlan.sh host1
Alpine Host 2:       /usr/local/bin/start-vxlan.sh host2
```

Start the four nodes, then on `Alpine Host 1` run:

```sh
ping 192.168.1.2
```

Inspect the unicast VXLAN on either router with:

```sh
ip -d link show vxlan10
bridge link
```

## Multicast VXLAN

Keep the host commands unchanged and use multicast mode on both routers:

```text
Alpine FRR Router 1: /usr/local/bin/start-vxlan.sh router1 multicast
Alpine FRR Router 2: /usr/local/bin/start-vxlan.sh router2 multicast
```

Restart the router nodes after changing their start commands. See
[Multicast.md](Multicast.md) for verification and packet capture commands.

## Startup Scripts

```text
router/start-vxlan.sh   Configures underlay IP, bridge, and VXLAN interface.
host/start-vxlan.sh     Configures the host address.
```

The scripts accept the node role in the start command and then leave an
interactive shell open for testing.

## Console Troubleshooting

The start command first configures the node, then starts an interactive shell.
If configuration fails, the script now prints the failure and opens a shell
so you can inspect the node instead of immediately losing its console.

If the console still closes immediately:

1. Rebuild both images with the commands above.
2. Remove old Docker nodes from the topology and add fresh instances.
3. Confirm the router templates use privileged mode.
4. Confirm routers have `eth0` and `eth1`, and hosts have `eth0`.
