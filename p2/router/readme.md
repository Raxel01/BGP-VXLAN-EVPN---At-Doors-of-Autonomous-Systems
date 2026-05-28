this is the Dockerfile for your router container.

build it : docker build -t alpine-frr .

After rebuilding, remove old router nodes already placed in a GNS3 topology
and add fresh instances from the updated templates.

## Start Again From Scratch

First stop the GNS3 topology and remove the old Alpine FRR Router nodes from
it. Then remove the old router image and rebuild it:

```sh
docker image rm -f alpine-frr:latest
cd /home/achaisne/Documents/vmShared/badass/p2/router
docker build -t alpine-frr .
```

If Docker says that a container still uses the image, find and remove that
container before deleting the image:

```sh
docker ps -a
docker rm -f <container_id>
docker image rm -f alpine-frr:latest
```

To delete every Docker container on your machine, including containers from
other projects, run this destructive reset command:

```sh
docker ps -aq | xargs -r docker rm -f
```

In GNS3:

Edit → Preferences
Docker containers
Click New
Choose Existing image
Select:
alpine-frr:latest

If you don’t see it, type manually:

alpine-frr

Then:

Name: Alpine FRR Router
Adapters: 2 or 3
Start command:

For router 1:

/usr/local/bin/start-vxlan.sh router1

For router 2:

/usr/local/bin/start-vxlan.sh router2

Console type: telnet

Finish.

Edit → Preferences
Docker containers
Select your Alpine FRR Router
Click Edit
Go to Category
Choose:
Routers
Apply / OK

Create two templates from the same image, one for each router start command.
The startup script configures the underlay IP, bridge, and VXLAN each time the
container starts, then opens an interactive Bash console. If configuration
fails, it opens the console with an error message so you can troubleshoot.

For the multicast VXLAN exercise, use these start commands instead:

/usr/local/bin/start-vxlan.sh router1 multicast
/usr/local/bin/start-vxlan.sh router2 multicast

The router template must run in privileged mode to create VXLAN interfaces.
