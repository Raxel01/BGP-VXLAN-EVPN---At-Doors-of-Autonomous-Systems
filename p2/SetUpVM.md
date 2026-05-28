VLAN = a way to split one physical local network/switch into several separate virtual networks.
Example: VLAN 10 for students, VLAN 20 for admins. They are separated even if they use the same switch.

One switch → several virtual switches

VXLAN = a way to carry a virtual Layer 2 network over a Layer 3/IP network.
It lets machines in different places behave as if they are on the same local network/switch.

One virtual switch stretched over routers/IP

Very short:

VLAN  = separate local networks inside switches
VXLAN = extend a local network across routed IP networks

--------------

Layer 2:
MAC addresses
switches
VLAN
VXLAN carries Ethernet frames

Layer 3:
IP addresses
routers
OSPF / IS-IS
BGP
AS

----------

Unicast:
one sender → one receiver

Broadcast:
one sender → everyone in the local network

Multicast:
one sender → a group of receivers

--------------

sudo add-apt-repository ppa:gns3/ppa
sudo apt install gns3-gui gns3-server
sudo apt install docker.io
sudo usermod -aG docker $USER

launch gns3
run appliance on my local computer
then
/usr/bin/gns3server
localhost
3080 TCP
then
it should notify for successful connection
then finish


