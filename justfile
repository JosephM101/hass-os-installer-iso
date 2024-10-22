set export  # Export the above defined variables to the current environment, for use by the build scripts


# Formulas
default:
  just --list


install-depends:
    sudo apt-get install debootstrap xorriso qemu-system-x86 ovmf live-build debian-archive-keyring -y


build:
    lb config
    sudo lb build


clean:
    sudo lb clean --all


[confirm("Are you sure you want to clean everything? (y/n)")]
fully-clean:
    sudo lb clean --all
    sudo lb clean --purge
    sudo rm -rf cache
    sudo rm -rf .build


run-qemu:
    #!/bin/bash
    iso=( *.iso ) # Find all iso files in the current directory

    qemu_args=(
        --bios /usr/share/ovmf/OVMF.fd
        -m 1024
        -smp 2
        -nic user,model=virtio-net-pci
        -cdrom ${iso[0]} # Take the first ISO image found
    )
    qemu-system-x86_64 ${qemu_args[@]}
    #sudo qemu-system-x86_64 --enable-kvm ${qemu_args[@]}


[confirm("This recipe will download, compile and install live-build from source (this is useful if the version offered by your distro is old).\n\nThe source will be downloaded and built within your home folder. It will remain, should you choose to uninstall it (sudo make uninstall).\nSome required build dependencies will be installed in order to continue (git, po4a, debhelper-compat, devscripts).\n\nWould you like to continue? [y/N]")]
install-livebuild-from-source:
    internal-build-livebuild-from-source
    internal-install-livebuild


[private]
internal-build-livebuild-from-source:
    #!/bin/bash
    # Based on instructions from https://live-team.pages.debian.net/live-manual/html/live-manual/installation.en.html
    cd ~ # Go to home directory
    echo Will now attempt to remove any installed version of live-build.
    sudo apt-get remove live-build -y
    set -e
    sudo apt-get install git po4a debhelper-compat devscripts  # Install build dependencies
    mkdir -p livebuild-src
    cd livebuild-src
    git clone https://salsa.debian.org/live-team/live-build.git live-build
    cd live-build
    dpkg-buildpackage -b -uc -us

[private]
internal-install-livebuild:
    #!/usr/bin/env python
    import os
