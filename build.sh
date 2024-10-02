set -e

ROOT_DIR="rootfs"

# Run debootstrap to create the chroot if it doesn't exist
[ ! -d $ROOT_DIR ] && sudo debootstrap --arch=amd64 buster $ROOT_DIR

set +e

cat << EOF | sudo chroot $ROOT_DIR
set -e
export DEBIAN_FRONTEND=noninteractive
debconf-set-selections <<< "grub-efi-amd64 grub2/update_nvram boolean false"
mount none -t proc /proc
mount none -t sysfs /sys
mount none -t devpts /dev/pts
export HOME=/root
export LC_ALL=C
export PS1="\e[01;31m(debootstrap):\W \$ \e[00m"

apt-get update
apt-get install dialog dbus -y
dbus-uuidgen > /var/lib/dbus/machine-id
apt-get remove python3.7 python3-minimal
apt-get install linux-image-amd64 live-boot linux-headers-amd64 grub-efi -y
apt-get clean -y
EOF

# Build and install Python within the CHROOT
PYTHON_INSTALL_SCRIPT=$( cat build-python.sh )
# cat build-python.sh | sudo chroot $ROOT_DIR


cat << EOF | sudo chroot $ROOT_DIR
# Cleanup before we leave
rm /var/lib/dbus/machine-id && rm -rf /tmp/*
umount /proc /sys /dev/pts
EOF

touch .build-done
