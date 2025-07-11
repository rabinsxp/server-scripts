#sudo virt-install --name AlmaLinux-server --ram=2048 --vcpus=2 --cpu host --hvm --
#disk path=/var/lib/libvirt/images/almalinuxservervml,size=20 --cdrom /var/lib/libvirt/boot/AlmaLinux-8.4-x86_64-DVD.iso --graphics vnc


#!/bin/bash

# AlmaLinux 8.4 VM Setup via ISO and VNC
# Author: Rabins Sharma Lamichhane
# Tested on AlmaLinux 9

set -e

# === Settings ===
VM_NAME="AlmaLinux-server"
ISO_URL="https://repo.almalinux.org/almalinux/8.4/isos/x86_64/AlmaLinux-8.4-x86_64-dvd.iso"
ISO_FILE="/var/lib/libvirt/boot/AlmaLinux-8.4-x86_64-dvd.iso"
DISK_FILE="/var/lib/libvirt/images/almalinuxservervm1.qcow2"
DISK_SIZE="20G"
RAM="2048"
VCPUS="2"
BRIDGE="br0"  # change to 'virbr0' if you're not using a custom bridge

echo "=== Creating directories if not exist ==="
sudo mkdir -p /var/lib/libvirt/boot
sudo mkdir -p /var/lib/libvirt/images

echo "=== Downloading AlmaLinux 8.4 ISO if not present ==="
if [ ! -f "$ISO_FILE" ]; then
  echo "Downloading ISO..."
  sudo wget -O "$ISO_FILE" "$ISO_URL"
else
  echo "ISO already exists."
fi

echo "=== Creating disk image ==="
sudo qemu-img create -f qcow2 "$DISK_FILE" "$DISK_SIZE"

echo "=== Starting virt-install ==="
sudo virt-install \
  --name "$VM_NAME" \
  --ram "$RAM" \
  --vcpus "$VCPUS" \
  --cpu host \
  --hvm \
  --disk path="$DISK_FILE",format=qcow2,bus=virtio \
  --cdrom "$ISO_FILE" \
  --os-variant almalinux8.4 \
  --network bridge="$BRIDGE",model=virtio \
  --graphics vnc \
  --noautoconsole

echo "✅ VM '$VM_NAME' created and booted to installer!"
echo "🔍 To view VNC port: virsh vncdisplay $VM_NAME"
echo "📡 Use a VNC client to connect (e.g., localhost:5900 or as shown above)"
