# NOTE: If you change anything in this file, you will need to run "just clean" and build from scratch.

args=(
--bootloaders grub-efi
--architecture amd64
--linux-flavours amd64
--image-name "haos-installer"
-b iso
--iso-volume "HAOS_INSTALLER"
--system live
--distribution bullseye
--apt apt-get
--apt-indices false
--apt-source-archives false
--archive-areas "main contrib"
--mode debian
#--apt-recommends false
--debian-installer none
--debian-installer-gui false
--win32-loader false
--debootstrap-options "--include=apt-transport-https,ca-certificates,openssl"
--memtest memtest86+
--iso-application "home-assistant-os-installer"
--iso-preparer "josephmignone"
--iso-publisher "josephmignone"
--compression xz
#--verbose
--color
#--interactive shell
)

#lb config ${args[@]}
lb config noauto ${args[@]}
