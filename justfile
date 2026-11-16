set export  # Export the above defined variables to the current environment, for use by the build scripts

qemu_test_disk_filename := "test-disk.qcow2"
build_config_filename := "build-config"
build_dir := "build"
output_dir := "output"

# Formulas
default:
  just --list


install-depends:
    sudo apt-get update
    sudo apt-get install -y live-build debootstrap xorriso debian-archive-keyring python3 python3-pip python3-packaging


install-qemu-depends:
    sudo apt-get update
    sudo apt-get install -y qemu-system-x86 ovmf


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
@check-live-build:
    python3 tools/check-live-build.py


# build-default: clean build


build: check-live-build check-build-config
    tools/setup-build-dir.sh
    cd $build_dir && lb config
    cd $build_dir && sudo lb build
    

@clean:
    cd $build_dir && sudo lb clean --all


@clean-output:
    rm -rf $output_dir


@clean-qemu:
    rm -f $qemu_test_disk_filename


[confirm("Are you sure you want to clean everything? (y/n)")]
@clean-all: clean clean-qemu
    cd $build_dir && sudo lb clean --all
    cd $build_dir && sudo lb clean --purge
    cd $build_dir && sudo rm -rf cache
    cd $build_dir && sudo rm -rf .build
    sudo rm -rf $build_dir


@run-qemu:
    tools/run_qemu.sh
