#sudo virt-install --name AlmaLinux-server --ram=2048 --vcpus=2 --cpu host --hvm --
#disk path=/var/lib/libvirt/images/almalinuxservervml,size=20 --cdrom /var/lib/libvirt/boot/AlmaLinux-8.4-x86_64-DVD.iso --graphics vnc

#!/bin/bash

# AlmaLinux 9 VM Setup via ISO and VNC
# Date: 11/07/2025

set -e

# === Settings ===
VM_NAME="AlmaLinux9-server"
ISO_URL="https://repo.almalinux.org/almalinux/9/isos/x86_64/AlmaLinux-9-latest-x86_64-dvd.iso"
ISO_FILE="/var/lib/libvirt/boot/AlmaLinux-9-latest-x86_64-dvd.iso"
DISK_FILE="/var/lib/libvirt/images/${VM_NAME}.qcow2"
DISK_SIZE="20G"
RAM="2048"
VCPUS="2"
BRIDGE="br0"       # or 'virbr0' if you're using NAT networking

# 1. Prepare directories
sudo mkdir -p /var/lib/libvirt/boot /var/lib/libvirt/images

# 2. Download ISO if needed
if [ ! -f "$ISO_FILE" ]; then
  echo "⬇️ Downloading AlmaLinux 9 ISO..."
  sudo wget -O "$ISO_FILE" "$ISO_URL"
else
  echo "✅ ISO already present: $ISO_FILE"
fi

# 3. Create QCOW2 disk
echo "💾 Creating virtual disk..."
sudo qemu-img create -f qcow2 "$DISK_FILE" "$DISK_SIZE"

# 4. Launch virt-install
echo "🚀 Booting installer via virt-install..."
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

# 5. Done
echo "✅ VM '$VM_NAME' created and installer running."
echo "🔍 VNC port: virsh vncdisplay $VM_NAME"
echo "🖥️ Connect via VNC at localhost:<port>"


