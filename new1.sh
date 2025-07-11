#!/bin/bash

# AlmaLinux Host Setup Script
# This script configures the AlmaLinux host for KVM virtualization

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   log_error "This script should not be run as root"
   exit 1
fi

log_info "Starting AlmaLinux Host Setup..."

# Update system
log_info "Updating system packages..."
sudo dnf update -y

# Install KVM and virtualization packages
log_info "Installing KVM and virtualization packages..."
sudo dnf install -y @virt virt-install virt-manager bridge-utils
sudo dnf install -y qemu-kvm libvirt libvirt-daemon-config-network
sudo dnf install -y cockpit cockpit-machines
sudo dnf install -y wget curl vim git htop nginx certbot python3-certbot-nginx

# Enable services
log_info "Enabling virtualization services..."
sudo systemctl enable --now libvirtd
sudo systemctl enable --now cockpit.socket

# Add user to virtualization groups
log_info "Adding user to virtualization groups..."
sudo usermod -aG libvirt $(whoami)
sudo usermod -aG kvm $(whoami)
newgrp libvirt

# Configure default network
log_info "Configuring default libvirt network..."
sudo virsh net-start default 2>/dev/null || true
sudo virsh net-autostart default

# Configure firewall
log_info "Configuring firewall..."
sudo firewall-cmd --add-service=ssh --permanent
sudo firewall-cmd --add-service=cockpit --permanent
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent
sudo firewall-cmd --reload

# Create VM storage directories
log_info "Creating VM storage directories..."
sudo mkdir -p /var/lib/libvirt/images/{isos,vms}
sudo chown -R qemu:qemu /var/lib/libvirt/images/
sudo chmod -R 755 /var/lib/libvirt/images/

# Download ISO files
log_info "Downloading guest OS ISOs..."
if [ ! -f /var/lib/libvirt/images/isos/ubuntu-24.04.2-server.iso ]; then
    log_info "Downloading Ubuntu 24.04.2 LTS ISO..."
    sudo wget -O /var/lib/libvirt/images/isos/ubuntu-24.04.2-server.iso \
        https://releases.ubuntu.com/24.04.2/ubuntu-24.04.2-live-server-amd64.iso
else
    log_info "Ubuntu ISO already exists, skipping download"
fi

if [ ! -f /var/lib/libvirt/images/isos/almalinux-9.6-server.iso ]; then
    log_info "Downloading AlmaLinux 9.6 ISO..."
    sudo wget -O /var/lib/libvirt/images/isos/almalinux-9.6-server.iso \
        https://repo.almalinux.org/almalinux/9.6/isos/x86_64/AlmaLinux-9.6-x86_64-dvd.iso
else
    log_info "AlmaLinux ISO already exists, skipping download"
fi

# Enable Nginx
log_info "Enabling Nginx..."
sudo systemctl enable nginx

log_info "Host setup completed successfully!"
log_info "You can now access Cockpit web interface at: https://$(hostname -I | awk '{print $1}'):9090"
log_info "Run the VM creation scripts to create your virtual machines."
