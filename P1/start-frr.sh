#!/bin/bash
# Start FRR (manages zebra, bgpd, ospfd, isisd as configured in /etc/frr/daemons)
/usr/lib/frr/frrinit.sh start

exec /bin/bash
