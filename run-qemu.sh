qemu_args=(
 --bios /usr/share/ovmf/OVMF.fd
 -m 512
 -smp 2
)

qemu-system-x86_64 ${qemu_args[@]}
