#iso_url=https://github.com/eliseomartelli/linux-based-router-distro/releases/download/v1.3.3b/linux-based-router-distro-v1.3.3b-amd64.iso
iso_url="C:/Users/Public/Downloads/ISO/vyos-1.3.3-amd64.iso"
iso_checksum_type="sha256"
iso_checksum="dd97e1a1faf065efb2f751a34d6ff89a1c3ba88aaf7307af009cbe6cb542fcb0"
vm_name="packer-vyos133"
configuration_version="8.0"
disk_size="128000"
// disk_additional_size=["150000"]
// https://www.packer.io/plugins/builders/hyperv/iso#cd_files
cd_files=[".\\http\\*"]
switch_name="Default Switch"
output_directory="C:/ProgramData/Microsoft/Windows/Virtual Hard Disks/Images/"
output_vagrant="../vbox/packer-vyos13x_wan-hv-g2.box"
vlan_id=""
vagrantfile_template="./vagrant-VyOS13x.rb"
ssh_username="vyos"
ssh_password="vyos"
provision_script_options="-z false"
// https://wiki.debian.org/CDDVD explanation for /dev/sr1
boot_command=["<wait3><enter><wait2><enter><wait2><enter>", 
// vyos login
"<wait20>vyos<enter>",
// password
"<wait3>vyos<enter>",
// https://docs.vyos.io/en/equuleus/installation/install.html#permanent-installation
// start install
"<wait3>install image<enter>",
// Would you like to continue? (Yes/No) [Yes]:
"<wait3><enter>",
// Partition (Auto/Parted/Skip) [Auto]:
"<wait3><enter>",
// Install the image on? [sda]:
"<wait3><enter>",
// This will destroy all data on /dev/sda. Continue? (Yes/No) [No]:
"<wait3>yes<enter>",
// How big of a root partition should I create? (2000MB - 4294MB) [4294]MB:
"<wait3><enter>",
// What would you like to name this image? [1.2.0-rolling+201809210337]:
"<wait3><enter>",
// Which configuration file should I copy to sda? [/opt/vyatta/etc/config.boot.default]:
// https://gns3.com/community/featured/create-a-vyos-image-with-cloud-init-to-pull-initial-configuration-from-iso
"<wait9><enter>",
// Enter password for user 'vyos':
"<wait3>vyos<enter>",
// Retype password for user 'vyos':
"<wait3>vyos<enter>",
// Which drive should GRUB modify the boot partition on? [sda]:
"<wait3><enter>",
// Done!
"<wait7>shutdown -r now<enter>",
"<wait7><enter>",
// vyos login
"<wait30>vyos<enter>",
// password
"<wait3>vyos<enter>",
"<wait3>sudo mount /dev/sr1 /mnt<enter>",
"<wait3>sudo /mnt/provision-dhcp.sh<enter>",
"<wait9>sudo /mnt/provision-equuleus-cloud-init.sh && sudo /mnt/provision-cleanup.sh && sudo umount /mnt && sudo poweroff<enter>"
// "<wait70>sudo /mnt/provision-cleanup.sh<enter>",
// "<wait5>sudo umount /mnt<enter>",
// "<wait3>sudo poweroff<enter>"
]
