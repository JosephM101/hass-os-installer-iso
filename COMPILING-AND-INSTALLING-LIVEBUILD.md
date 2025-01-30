# Compiling and Installing `live-build` manually

As I mentioned in README.md, the version of `live-build` shipped with some Debian-based Linux distros (I used Linux Mint which uses Ubuntu repositories) is several years behind at the time of writing (I got a version from 2012), even with the latest repositories. To get around this, we can manually compile and install the latest version of `live-build`.

## Build
The routines below has been adapted from [these instructions](https://live-team.pages.debian.net/live-manual/html/live-manual/installation.en.html). What this boils down to is downloading the latest source, building a `deb` package, and then installing that to our system.

1. First off, let's remove any currently installed version of `live-build`.
    
        sudo apt-get remove live-build

2. Next up, we'll need to install required build dependencies.

        sudo apt-get install git po4a debhelper-compat devscripts

3. Now, we'll create a build directory in our home folder.

        cd ~  # Go to home directory
        mkdir -p livebuild-src  # Create a directory to build inside of
        cd livebuild-src

4. Now we'll grab the source code, move into the directory, and start building the package!

        git clone https://salsa.debian.org/live-team/live-build.git live-build
        cd live-build
        dpkg-buildpackage -b -uc -us

5. Now that that's finished, we should have a .deb package in the parent directory. To install it, we'll use the `dpkg` command:

        cd ..  # Go to the parent directory
        sudo dpkg -i live-build*.deb

Awesome, we've done it! Test out your new live-build installation by calling `lb --version`!

    $ lb --version
    20240810


Feel free to delete the directory we created in step 1: 

    cd ~
    rm -rf livebuild-src
