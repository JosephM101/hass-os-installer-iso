# Remove old version
sudo apt-get remove -y live-build

# Install build dependencies
sudo apt-get install -y git po4a debhelper-compat devscripts

# Clone live-build source
mkdir -p livebuild-src  # Create a directory to build inside of
cd livebuild-src
git clone https://salsa.debian.org/live-team/live-build.git live-build

# Build
cd live-build
dpkg-buildpackage -b -uc -us

# Install
cd ..
sudo dpkg -i live-build*.deb
