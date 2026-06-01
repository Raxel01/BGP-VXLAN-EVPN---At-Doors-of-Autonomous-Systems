#!/usr/bin/env bash
# ==============================================================================
#  install_gns3_docker_24.sh
#  Installs GNS3 (GUI + Server) and Docker Engine on Ubuntu 24.04.4 LTS
#  Tested against: Ubuntu 24.04.4 LTS (Noble Numbat) — GNS3 2.2.58.x
#
#  Usage:
#    chmod +x install_gns3_docker_24.sh
#    ./install_gns3_docker_24.sh
#
#  Run as your normal user — NOT root. sudo is called internally.
# ==============================================================================

set -euo pipefail

# ── Colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

[[ "$EUID" -eq 0 ]] && error "Do NOT run as root. Run as your normal user."

CURRENT_USER="$USER"
info "Running as user: ${BOLD}${CURRENT_USER}${NC}"

# ── 1. System update ──────────────────────────────────────────────────────────
info "Updating and upgrading system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y
success "System up to date."

# ── 2. Prerequisites ──────────────────────────────────────────────────────────
info "Installing prerequisites..."
sudo apt-get install -y \
  software-properties-common \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release
# Enable universe repo (required for some GNS3 deps)
sudo add-apt-repository -y universe
success "Prerequisites installed."

# ── 3. GNS3 ──────────────────────────────────────────────────────────────────
# NOTE: On Ubuntu 24.04 (Noble), gns3-ubridge does NOT exist as a standalone
# package. ubridge is automatically pulled as a dependency of gns3-server.
# Only gns3-gui and gns3-server are needed.

info "Adding GNS3 official PPA (ppa:gns3/ppa)..."
sudo add-apt-repository -y ppa:gns3/ppa
sudo apt-get update -y

info "Installing GNS3 (gns3-gui + gns3-server)..."
# ubridge is installed automatically as a dependency of gns3-server
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  gns3-gui \
  gns3-server

info "Configuring Wireshark for non-root packet capture..."
echo "wireshark-common wireshark-common/install-setuid boolean true" \
  | sudo debconf-set-selections
sudo dpkg-reconfigure -f noninteractive wireshark-common

success "GNS3 installed. (ubridge pulled in automatically as dependency)"

# ── 4. Docker Engine ──────────────────────────────────────────────────────────
info "Removing any conflicting old Docker packages..."
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
  sudo apt-get remove -y "$pkg" 2>/dev/null || true
done

info "Adding Docker's official GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

info "Adding Docker APT repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y

info "Installing Docker Engine..."
sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

success "Docker Engine installed."

# ── 5. Enable Docker service ──────────────────────────────────────────────────
info "Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker
success "Docker service is active."

# ── 6. Add user to all required groups ───────────────────────────────────────
# docker   → run Docker without sudo
# wireshark→ packet capture in GNS3
# ubridge  → GNS3 virtual bridge (created by gns3-server install)
# kvm      → QEMU/KVM acceleration
# libvirt  → libvirt backend (optional but recommended)

info "Adding ${BOLD}${CURRENT_USER}${NC} to required groups..."
for group in docker wireshark ubridge kvm libvirt; do
  if getent group "$group" > /dev/null 2>&1; then
    sudo usermod -aG "$group" "$CURRENT_USER"
    success "  → Added to group: $group"
  else
    warn "  → Group '$group' not found, skipping."
  fi
done

# ── 7. Verify ─────────────────────────────────────────────────────────────────
echo ""
info "Verifying installations..."
GNS3_VER=$(gns3server --version 2>/dev/null || echo "not found")
DOCKER_VER=$(docker --version 2>/dev/null || echo "not found")
UBRIDGE_VER=$(ubridge --version 2>/dev/null | head -1 || echo "not found")
echo -e "  GNS3 server : ${BOLD}${GNS3_VER}${NC}"
echo -e "  ubridge     : ${BOLD}${UBRIDGE_VER}${NC}"
echo -e "  Docker      : ${BOLD}${DOCKER_VER}${NC}"

# ── 8. Done ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║           Installation Complete!                     ║${NC}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}${BOLD}⚠  REBOOT or log out/in for group membership to take effect!${NC}"
echo ""
echo -e "${BOLD}After reboot, verify:${NC}"
echo -e "  docker run hello-world     # Docker works without sudo"
echo -e "  gns3                       # Launch GNS3 GUI"
echo ""
