#sudo virt-install --name AlmaLinux-server --ram=2048 --vcpus=2 --cpu host --hvm --
#disk path=/var/lib/libvirt/images/almalinuxservervml,size=20 --cdrom /var/lib/libvirt/boot/AlmaLinux-8.4-x86_64-DVD.iso --graphics vnc

#!/bin/bash

# AlmaLinux 9.4 VM Setup via ISO and VNC
# Author: Rabins Sharma Lamichhane
# Version: 2025-07-11

set -e

# === Settings ===
VM_NAME="AlmaLinux9-server"
ISO_URL="https://repo.almalinux.org/almalinux/9.4/isos/x86_64/AlmaLinux-9.4-x86_64-dvd.iso"
ISO_FILE="/var/lib/libvirt/boot/AlmaLinux-9.4-x86_64-dvd.iso"
DISK_FILE="/var/lib/libvirt/images/almalinux9-server.qcow2"
DISK_SIZE="20G"
RAM="2048"
VCPUS="2"
BRIDGE="br0"  # Or use 'virbr0' if you are using NAT

# === Step 1: Prepare directories ===
echo "📁 Creating image/ISO directories..."
sudo mkdir -p /var/lib/libvirt/boot
sudo mkdir -p /var/lib/libvirt/images

# === Step 2: Download ISO if needed ===
if [ ! -f "$ISO_FILE" ]; then
  echo "⬇️ Downloading AlmaLinux 9.4 ISO..."
  sudo wget -O "$ISO_FILE" "$ISO_URL"
else
  echo "✅ ISO already exists: $ISO_FILE"
fi

# === Step 3: Create QCOW2 disk ===
echo "💾 Creating virtual disk..."
sudo qemu-img create -f qcow2 "$DISK_FILE" "$DISK_SIZE"

# === Step 4: Install VM with virt-install ===
echo "🚀 Launching virt-install to boot the installer..."

sudo virt-install \
  --name "$VM_NAME" \
  --ram "$RAM" \
  --vcpus "$VCPUS" \
  --cpu host \
  --hvm \
  --disk path="$DISK_FILE",format=qcow2,bus=virtio \
  --cdrom "$ISO_FILE" \
  --os-variant almalinux9 \
  --network bridge="$BRIDGE",model=virtio \
  --graphics vnc \
  --noautoconsole

# === Step 5: Done ===
echo "✅ VM '$VM_NAME' created and is now running."
echo "🔍 Run: virsh vncdisplay $VM_NAME  → to get the VNC port."
echo "🖥️ Use a VNC viewer to connect to localhost:<port>"

