# To be run in CHROOT!

set -e
PY_VERSION=3.11.1

packages=(
  wget
  git
  curl
  build-essential
  clang
  libreadline-dev
  libncurses5-dev
  libncursesw5-dev
  libgdbm-dev
  libc6-dev
  libz-dev
  libbz2-dev
  tk-dev
  libsqlite3-dev
  libreadline-dev
  liblzma-dev
  libffi-dev
  libssl-dev
  zlib1g-dev
  xz-utils
  llvm
)

apt-get install -y "${packages[@]}"

# Download and extract Python source tarball
wget -c https://www.python.org/ftp/python/$PY_VERSION/Python-$PY_VERSION.tgz
tar xvf Python-$PY_VERSION.tgz
cd Python-$PY_VERSION

# Build & Install
./configure --enable-optimizations --with-ensurepip=install
make -j${nproc}
make install

# Cleanup
echo Cleaning up...
cd ..
rm -rf Python-$PY_VERSION
rm Python-$PY_VERSION.tgz