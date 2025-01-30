set export  # Export the above defined variables to the current environment, for use by the build scripts

qemu_test_disk_filename := "test-disk.qcow2"
build_config_filename := "build-config"

# Formulas
default:
  just --list


install-depends:
    sudo apt-get install debootstrap xorriso qemu-system-x86 ovmf live-build debian-archive-keyring -y


[private]
check-build-config:
    #!/bin/bash
    echo -n "Checking $build_config_filename... "
    if [ ! -e $build_config_filename ]; then
        echo "Could not find $build_config_filename"
        exit 1
    fi
    echo "ok"


[private]
check-live-build:
    python3 tools/check-live-build.py


build-default: clean build


build: check-live-build check-build-config
    lb config
    sudo lb build


@clean:
    sudo lb clean --all
    rm -f $qemu_test_disk_filename


[confirm("Are you sure you want to clean everything? (y/n)")]
@fully-clean:
    sudo lb clean --all
    sudo lb clean --purge
    sudo rm -rf cache
    sudo rm -rf .build
    rm -f $qemu_test_disk_filename


@run-qemu:
    #!/bin/bash
    iso=( *.iso ) # Find all iso files in the current directory

    qemu-img create -f qcow2 $qemu_test_disk_filename 32G
    qemu_args=(
        --bios /usr/share/ovmf/OVMF.fd
        -m 1024
        -smp 2
        -nic user,model=virtio-net-pci
        -cdrom ${iso[0]} # Use the first ISO image found
        -hda test-disk.qcow2
    )
    qemu-system-x86_64 ${qemu_args[@]}
    #sudo qemu-system-x86_64 --enable-kvm ${qemu_args[@]}
