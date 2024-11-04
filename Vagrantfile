# -*- mode: ruby -*-
# vi: set ft=ruby :

# Create a directory where the final ISO image will end up
Dir.mkdir("out") unless Dir.exist?("out")

Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  config.vm.box = "debian/bookworm64"
  config.vm.box_version = "12.20240905.1"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 4
  end

  config.vm.post_up_message = ""

  config.vm.provision "shell" do |shell|
    shell.keep_color = true
    shell.inline = <<-SHELL
      REPO_DIR="/vagrant" # The path on the host where the Vagrantfile is located (in this case, the root of the repository directory)
      OUTPUT_DIR="$REPO_DIR/out" # The path on the host system (within the repository directory) where the final ISO will end up.
      TEMP_BUILD_DIR="/build-temp" # The path within the container where building will take place, separate from the host filesystem.

      # Update APT and install some packages we'll need
      apt-get update
      apt-get install -y wget curl git


      # Install casey/just (https://github.com/casey/just)
      mkdir -p ~/bin
      curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/bin  # Download the prebuilt "just" binary into ~/bin
      export PATH="$PATH:$HOME/bin" # Add ~/bin to PATH so that we can run "just"


      build_and_install_livebuild () {
        # Install live-build from source
        # Based on instructions from https://live-team.pages.debian.net/live-manual/html/live-manual/installation.en.html
        echo ""
        echo "Start building live-build from source"

        echo "Clone live-build"
        cd ~ # Go to home directory
        sudo apt-get install -y git po4a debhelper-compat devscripts  # Install build dependencies
        mkdir -p livebuild-src && cd livebuild-src
        git clone https://salsa.debian.org/live-team/live-build.git live-build
        cd live-build
        
        echo ""
        echo "Compile live-build"
        dpkg-buildpackage -b -uc -us

        echo ""
        echo "Install live-build"
        cd ..
        find . -name "*.deb" -print0 | xargs -0 dpkg -i # Install live-build deb
      }

      # Uncomment the line below if you encounter issues with live-build (eg. the shipped version is broken, out-of-date or doesn't support something we need)
      # This will build and install live-build from source, rather than use the one provided by Debian's repos.
      #build_and_install_livebuild

      # Copy the contents of the repository (including config files) to a directory within the Linux container for building.
      # We need to do this because we can't count on the host filesystem to support what we need to do (ex. NTFS wouldn't support this, but ext4 would)
      rm -rf $TEMP_BUILD_DIR  # Delete the temporary build directory if it exists
      git clone $REPO_DIR $TEMP_BUILD_DIR && cd $TEMP_BUILD_DIR  # Clone into temp directory (I used git clone so that other files like old build artifacts wouldn't be transferred over)
      cp $REPO_DIR/build-config .  # Copy the build-config file from host repo
      just install-depends  # Install build dependencies
      just build  # Start the build

      # Copy built ISO file to out dir
      echo ""
      echo "Copying build artifacts to $OUTPUT_DIR"
      rsync -av --progress --stats --include='*.iso' --exclude='*' $TEMP_BUILD_DIR/ $OUTPUT_DIR/

      echo "Build complete."

      # Shut down the guest
      shutdown now
    SHELL
  end
end
