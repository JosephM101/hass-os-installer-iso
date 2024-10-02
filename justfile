default: build

install-depends:
    sudo apt-get install debootstrap xorriso qemu-system-x86 ovmf live-build -y

build:
    ./build.sh

clean:
    # Delete built rootfs directory and files
    # A password may be required to continue

    sudo rm -rf rootfs
    rm -rf out
    rm -f .build-done

iso:
    # [ -d ".build-done" ] && echo "A built root FS exists"
    ./create-boot-iso-structure.sh out/iso
    # Copy GRUB bootloader

run-qemu:
    ./run-qemu.sh

build-full: build iso
