#!/bin/bash
iso=( *.iso ) # Find all .iso files in the current directory
if [ ! -e ${iso[0]} ]; then
    echo "E: Couldn't start QEMU: An ISO image wasn't found. Have you built the image?"
    exit
fi

qemu-img create -f qcow2 $qemu_test_disk_filename 32G
qemu_args=(
    --bios /usr/share/ovmf/OVMF.fd
    -m 1024
    -smp 2
    -nic user,model=virtio-net-pci
    -cdrom ${iso[0]} # Use the first ISO image found
    -hda test-disk.qcow2
    -display sdl
)
qemu-system-x86_64 ${qemu_args[@]}
#sudo qemu-system-x86_64 --enable-kvm ${qemu_args[@]}
