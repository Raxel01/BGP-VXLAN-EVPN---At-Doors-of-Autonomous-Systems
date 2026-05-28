#!/bin/bash
set -euo pipefail

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1 || true

# Start Quagga services
if [ -x /etc/init.d/quagga ]; then
  /etc/init.d/quagga start || true
fi

# Keep container running
tail -f /dev/null
