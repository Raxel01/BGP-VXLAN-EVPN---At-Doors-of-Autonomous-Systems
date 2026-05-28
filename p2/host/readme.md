this is the Dockerfile for your host container (users).

build it : docker build -t alpine-host .

After rebuilding, remove old host nodes already placed in a GNS3 topology and
add fresh instances from the updated templates.

## Start Again From Scratch

First stop the GNS3 topology and remove the old Alpine Host nodes from it.
Then remove the old host image and rebuild it:

```sh
docker image rm -f alpine-host:latest
cd /home/achaisne/Documents/vmShared/badass/p2/host
docker build -t alpine-host .
```

If Docker says that a container still uses the image, find and remove that
container before deleting the image:

```sh
docker ps -a
docker rm -f <container_id>
docker image rm -f alpine-host:latest
```

To delete every Docker container on your machine, including containers from
other projects, run this destructive reset command:

```sh
docker ps -aq | xargs -r docker rm -f
```

In GNS3:

Edit -> Preferences
Docker containers
Click New
Choose Existing image
Select:
alpine-host:latest

If you don't see it, type manually:

alpine-host

Then:

Name: Alpine Host
Adapters: 1
Start command:

For host 1:

/usr/local/bin/start-vxlan.sh host1

For host 2:

/usr/local/bin/start-vxlan.sh host2

Console type: telnet

Finish.

Edit -> Preferences
Docker containers
Select your Alpine Host
Click Edit
Go to Category
Choose:
End devices
Apply / OK

Create two templates from the same image, one for each host start command.
The startup script assigns the host IP each time the container starts, then
opens an interactive shell console. If configuration fails, it opens the
console with an error message so you can troubleshoot.
