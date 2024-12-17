#!/bin/bash

# To use image with bios use "dd" mode to write iso!
#
# Grub modules descriptions:
# https://www.linux.org/threads/understanding-the-various-grub-modules.11142/


rm -rf iso tmp

# copy grub config
mkdir -p iso/boot/grub
cp grub.cfg iso/boot/grub/

# copy grub modules
cp -r /usr/lib/grub/i386-pc iso/boot/grub/
cp -r /usr/lib/grub/x86_64-efi iso/boot/grub/

# make bios loader
grub-mkimage \
    --directory "/usr/lib/grub/i386-pc" \
    --prefix "/boot/grub" \
    --output "iso/boot/grub/i386-pc/eltorito.img" \
    --format "i386-pc-eltorito" \
    --compression "auto" \
    --config "./grub.cfg" \
    "linux" \
    "normal" \
    "search" \
    "biosdisk" \
    "iso9660"

# make efi loader
mkdir -p tmp/efi/boot/
grub-mkimage \
    --directory "/usr/lib/grub/x86_64-efi" \
    --prefix "/boot/grub" \
    --output "tmp/efi/boot/bootx64.efi" \
    --format "x86_64-efi" \
    --compression "auto" \
    --config "grub.cfg" \
    "part_gpt" \
    "part_msdos" \
    "fat" \
    "iso9660"
mformat -C -f 2880 -L 16 -i tmp/efi.img ::
mcopy -s -i tmp/efi.img tmp/efi ::/
cp tmp/efi.img iso/boot/grub/x86_64-efi/

# copy kernel and initrd
cp /boot/vmlinuz /boot/initrd.img iso/boot/

# make squashfs with bootable filesystem
mkdir -p iso/live
mksquashfs / iso/live/filesystem.squashfs -e /iso /proc /run /sys /tmp /.dockerenv

# make iso
xorrisofs \
    -graft-points \
    -eltorito-boot boot/grub/i386-pc/eltorito.img \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
    --grub2-boot-info \
    --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
    --efi-boot boot/grub/x86_64-efi/efi.img \
    -o image.iso \
    -r \
    iso


# grub-mkrescue -v -o image1.iso iso
