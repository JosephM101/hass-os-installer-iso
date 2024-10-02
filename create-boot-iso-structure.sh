make_directory() {
    echo "Creating $1"
    mkdir -p $1
}


if [ $# -eq 0 ]; then
  echo "No arguments supplied"
  exit 1
fi

ISO_ROOT_DIR=$1

echo "Creating ISO structure..."
make_directory $ISO_ROOT_DIR/boot/grub
