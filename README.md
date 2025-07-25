# hass-os-installer-iso
### The (unofficial) Home Assistant OS Installer!

A simple live system based on `debian-bookworm` to quickly install Home Assistant OS onto `x86_64-generic` targets, including virtual machines and bare-metal systems.

This live system only supports *AMD64* systems with *UEFI* bootloaders. These are the requirements for Home Assistant OS (amd64), and therefore they are the requirements here.

The image is built using `live-build`, which is a system for creating customized Debian-based live images.

<b>NOTE: This project is still in development. As such, ISO images will not be published in Releases at this time and will need to be [built manually](#Build). An Actions workflow will soon be available once consistent, autonomous builds are possible. The plan is to have images be automatically built when new HAOS versions are released. Contributions in the form of pull requests are welcome!</b>

<hr></hr>

## How to use
Like any bootable ISO file, you can write it to a USB drive using [balenaEtcher](https://etcher.balena.io/) or [Rufus](https://rufus.ie/en/), copy it to a drive using the [Ventoy bootloader](https://www.ventoy.net/en/index.html) (my personal favorite), or optionally burn it to a CD (it's small enough!). If you're deploying to a virtual machine, you can mount it like any other ISO.

> Personally, I like using the [Ventoy](https://www.ventoy.net/en/index.html) bootloader on my USB drives because it allows me to store multiple bootable ISO files as well as other files on a single flash drive without needing to reformat for a different operating system every time.

Once you have booted the installer, you will be asked to choose the disk where you want to install Home Assistant from a list. To make sure you don't accidentally select the wrong thing, you will be asked TWICE to confirm your selection. Once you have confirmed that you would like to continue with the installation, the Home Assistant OS image (included in the ISO) will be written straight to the selected drive, and once complete, you will be given the option to either reboot into your new installation or shut down your machine.
> I may, in the future, add the ability to download the latest version of Home Assistant OS from the internet directly from the installer. This may be offered in the form of a separate ISO image labeled "netinstall", but the feature could also be included in the main ISO.


## Why?
I wanted to install Home Assistant OS onto a VM on my Fedora Server, and it took many more steps than I would've otherwise liked. To remedy this, I wrote a simple and straightforward CLI app in Python and wrapped it with a minimal Debian live enivronment. Traditionally, one might use something like a live Ubuntu environment and the `dd` command to write the Home Assistant OS image onto the intended drive; a method which I would consider to not be very beginner-friendly.

I created this project with the goal of creating a small, simple and straightforward-to-use bootable installer that automates as much as reasonably possible. It has helped me in deploying Home Assistant OS, and I hope that it helps someone else :)


## Warnings
I can't gurantee that this script is foolproof, and am not responsible for lost data. You are given two warnings before you wipe any of your disks where you are required to answer "yes" two times. If you'd like to go the extra mile, you can disconnect/remove from your target system any drives that contain data you wouldn't want to lose. I wrote the installer in such a way that accidental data wiping should not happen, but "should not" does not mean "never". Better safe than sorry!


## The project structure
Everything you'll want to see and/or modify that has to do with customizing the Debian system can be found in the `config/` and `auto/` directories at the root of the repository. Go into the `config/includes.chroot/bin` directory, and you'll find the Python-based CLI installer script that gets automatically launched on `tty1` when the Debian image boots up. Keep on reading to find out how!

<b>Hook scripts</b> are scripts that are automatically executed during the build process. They are used to do things such as download the HAOS image and set up auto-start for the installer. They can be found in `config/hooks/live`. All hook scripts are helpfully named based on what they do. For more information about how hook scripts work, [check out the customizing-contents section of debian-live's manual.](https://live-team.pages.debian.net/live-manual/html/live-manual/customizing-contents.en.html)
> Some hooks are marked as `.chroot-disabled` becuase they aren't needed and this prevents them from running. Rather than delete them (I may want them for future reference), I simply renamed them.

The `config/package-lists` directory contains files that each contain a list of packages to be installed in the output image.

#### The GRUB bootloader
The configuration files for the GRUB bootloader can be found in `config/bootloaders/grub-pc`. The file we care about is `grub.cfg.template`. Those familar with GRUB configuration might be asking "<i>What's with the .template extension?</i>"

Well, despite how capable <i>live-build</i> is, without editing its source code (which isn't exactly ideal), you can only go so far with customization. So I've added my own placeholder within `grub.cfg.template` called `@HAOS_VERSION@`, and I've added some lines to `auto/config` which replaces that placeholder with the version of Home Assistant OS included on the image (as defined in the `build-config` file at the repository root), and outputs that to a new `grub.cfg` file in the same directory, at which point <i>live-build</i> can fill in the rest of the placeholders. All that mess allows me to customize the name of the boot entry.


## Build

### Update the build-config file
Environment variables for the build process are stored in the `build-config` file at the root of the directory and are sourced by various scripts, such as those in the `auto/` directory. 

Change the value of `CFG_HAOS_VERSION` to the version of the Home Assistant OS that you want to include in your resulting image (ex. 12.4). Realistically you would change this value to be the latest version. You can get the version number of the latest release from the [Home Assistant OS GitHub page](https://github.com/home-assistant/operating-system/releases/latest).

This variable is also used to name the ISO and the GRUB boot entry, among other things.

    # The version of Home Assistant OS to be downloaded and included in the installer ISO
    CFG_HAOS_VERSION=12.4

<i>(A way to automatically retrieve and update this information will hopefully be coming soon)</i>

### How to build
There are two methods for building. The first method requires that you are on a Debian-based distro (I used Linux Mint 21 Wilma in testing). The second method requires that you have [Vagrant](https://developer.hashicorp.com/vagrant/install) and [VirtualBox](https://www.virtualbox.org/wiki/Downloads) installed, and works on Linux, Windows and macOS.

- [Build on a Debian-based system](#building-on-a-debian-based-system)
- [Build using Vagrant](#building-with-vagrant)


## Building on a Debian-based system

This repository uses the [`just`](https://github.com/casey/just) command runner, which will need to be installed on your host system. `just` is a command runner like `make`, however is much simpler and was much more attractive for my use cases.

> I would recommend against installing the `just` package from Debian's repositories. At the time of writing, it is several versions behind, and missing features that we need.

#### Dependency: `just`
To install `just` on your system, run the following commands (`bash` is assumed):

    # create ~/bin
    mkdir -p ~/bin

    # download and extract just to ~/bin/just
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash     -s -- --to ~/bin

    # add `~/bin` to the paths that your shell searches for executables
    # this line should be added to your shells initialization file,
    # e.g. `~/.bashrc` or `~/.zshrc`
    export PATH="$PATH:$HOME/bin"

> Some shell initialization files are already set up to add `$HOME/bin` to your PATH. You can test this by opening a new terminal and running 'just'. If you get "command not found", run one of the commands below for your shell:

    # for bash
    echo 'export PATH="$PATH:$HOME/bin"' >> ~/.bashrc

    # for zsh
    echo 'export PATH="$PATH:$HOME/bin"' >> ~/.zshrc



If you have the Rust toolchain and Cargo installed, alternatively you can install `just` by running:

    cargo install just  # Will build the latest version, and will also automatically be included in your PATH

#### Dependency: `live-build`
Currently, the version of `live-build` included in Ubuntu's repositories is many years behind. If you are building on Ubuntu, and run into an issue with the `live-build` version check failing when running `just build`, you can compile and install from source. See [Compiling and Installing live-build](COMPILING-AND-INSTALLING-LIVEBUILD.md)

### Run the build
In the repository directory, run the following command to start building the ISO:

    just build

If you have QEMU installed and would like to test the resulting ISO image, you can run:

    just run-qemu

You can also specify multiple recipes to run, and they will be executed sequentially; one after the other. To do a clean build, run:

    just clean build



## Building with Vagrant (recommended)
The [Vagrant](https://www.vagrantup.com/) method works by spinning up a Linux virtual machine, running the build scripts inside of it, and then copying the build artifacts (in this case, the final ISO) to your host system. This allows the build process to be cross-platform. And here's the best part: installing dependencies and such are all handled for you in this method.

This repository ships with a Vagrantfile in the top-most directory that contains a modified build script that builds the image.

<b>NOTE: This method requires an AMD64 host system with VirtualBox installed. Other providers are available, but I have not tested them.</b>


### Step 1: Install Vagrant
First off, you'll need to have Vagrant installed. You can [install Vagrant from here](https://developer.hashicorp.com/vagrant/install). 

To check if your Vagrant installation is working, open a terminal or PowerShell window and run the following command:

    vagrant --version

If you see a line like `Vagrant 2.4.2` in your output, congratulations! You can continue on to Step 2! If you see anything else, such as "command not found", Vagrant probably isn't installed or didn't install correctly.

Awesome! Now you just need to install a compatible hypervisor!

### Step 2: Install VirtualBox
Vagrant requires a provider (in other words, a hypervisor) in order to work. In this case, we're going to use VirtualBox, because it is cross-platform and supported on all major operating systems.

You can install VirtualBox from here: https://www.virtualbox.org/wiki/Downloads

<b>NOTE: Other hypervisors are supported by Vagrant, however they have not been tested with this project.</b>

<i>When you've installed VirtualBox, continue to the next step.</i>

### Step 3: Start the build
Open a terminal in the current directory of the repository, and run the following command:

    vagrant up

This will download the `debian/bookworm64` box, spin up a VirtualBox VM, and run the build within it. When the build completes, the resulting ISO file will be copied to the `out` folder in the repository.

When Vagrant finishes, the resulting virtual machine is left behind. If you'd like to destroy it and regain some disk space, run the following command:

    vagrant destroy

This will destroy the virtual machine, but won't delete the box that was downloaded and used to create the virtual machine. If you choose not to delete the box, it won't need to be redownloaded if you decide to run `vagrant up` again.

If you want to delete the box and reclaim disk space, run the following command:

    vagrant box remove

<hr>

## Roadmap

- [x] Make installer functional (Home Assistant OS is installed to internal drive)
- [ ] Move to using TOML for build definitions
- [ ] Streamline build process (and make it less janky)
- [ ] Add action for automatically building new images when new versions of HAOS are released
