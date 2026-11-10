%post
# Remove any existing console settings
sed -i 's/ console=[^ ]*//g' /etc/default/grub

# Append the new console settings
sed -i 's/^GRUB_CMDLINE_LINUX=.*/& console=ttyS1,115200 console=tty0/' /etc/default/grub

# if console was appended after the closing quote: " console=..., remove that prefixed quote
sed -i 's/" console=/ console=/g' /etc/default/grub

# close the quotes if they were removed
if ! grep -q '^GRUB_CMDLINE_LINUX=.*"$' /etc/default/grub; then
    sed -i '/^GRUB_CMDLINE_LINUX=/s/$/"/' /etc/default/grub
fi

# set or replace GRUB_TERMINAL
sed -i '/^GRUB_TERMINAL=/c\GRUB_TERMINAL="console serial"' /etc/default/grub

# set or replace GRUB_SERIAL_COMMAND
sed -i '/^GRUB_SERIAL_COMMAND=/c\GRUB_SERIAL_COMMAND="serial --speed=115200"' /etc/default/grub

# add if GRUB_TERMINAL and/or GRUB_SERIAL_COMMAND don't exist
grep -q '^GRUB_TERMINAL=' /etc/default/grub || echo 'GRUB_TERMINAL="console serial"' >> /etc/default/grub
grep -q '^GRUB_SERIAL_COMMAND=' /etc/default/grub || echo 'GRUB_SERIAL_COMMAND="serial --speed=115200"' >> /etc/default/grub

if [ -d /sys/firmware/efi ]; then
    grub_dir=$(dirname $(find /boot/efi/EFI/ -maxdepth -name grub.cfg))
    grub_cfg=${grub_dir}/grub.cfg
    grub2-mkconfig -o ${grub_cfg}
else
    grub2-mkconfig -o /boot/grub2/grub.cfg
fi

systemctl enable serial-getty@ttyS1.service

%end
