locals {
  count = 1
}

data "ignition_config" "ignition" {
  count       = local.count
  disks       = [data.ignition_disk.data.rendered]
  filesystems = [data.ignition_filesystem.data.rendered]
  systemd = [
    data.ignition_systemd_unit.data.rendered,
    data.ignition_systemd_unit.rpm-ostree.rendered
  ]
  directories = [data.ignition_directory.podmgr.rendered]
  users = [
    data.ignition_user.admin.rendered,
    data.ignition_user.podmgr.rendered
  ]
  files = [
    data.ignition_file.hostname[count.index].rendered,
    data.ignition_file.eth0[count.index].rendered,
    data.ignition_file.disable_dhcp.rendered,
    data.ignition_file.rpms.rendered
  ]
  links = [data.ignition_link.timezone.rendered]
}

# https://docs.fedoraproject.org/en-US/fedora-coreos/hostname/
data "ignition_file" "hostname" {
  count = local.count
  path  = "/etc/hostname"
  mode  = 420 # OCT: 0644
  content {
    content = local.count <= 1 ? "${var.vm_name}" : "${var.vm_name}${count.index + 1}" # 
  }
}

# https://docs.fedoraproject.org/en-US/fedora-coreos/time-zone/
data "ignition_link" "timezone" {
  path   = "/etc/localtime"
  target = "../usr/share/zoneinfo/Asia/Shanghai"
}

data "ignition_disk" "data" {
  device     = "/dev/sdb"
  wipe_table = false
  partition {
    number  = 1
    label   = "data"
    sizemib = 0
  }
}

data "ignition_filesystem" "data" {
  device          = "/dev/disk/by-partlabel/data"
  format          = "xfs"
  wipe_filesystem = false
  label           = "data"
  path            = "/var/home/podmgr"
}

# the ignition provider does not provide filesystems.with_mount_unit like butane
# https://coreos.github.io/butane/config-fcos-v1_5/
# had to create the systemd mount unit manually
# to debug, run journalctl --unit var-home-podmgr.mount -b-boot
# https://github.com/getamis/terraform-ignition-etcd/blob/6526ce743d36f7950e097dabbff4ccfb41655de7/volume.tf#L28
# https://github.com/meyskens/vagrant-coreos-baremetal/blob/5470c582fa42f499bc17eb501d3e592cf85caaf1/terraform/modules/ignition/systemd/files/data.mount.tpl
# https://unix.stackexchange.com/questions/225401/how-to-see-full-log-from-systemctl-status-service/225407#225407
data "ignition_systemd_unit" "data" {
  # mind the unit name, The .mount file must be named based on the path (e.g. /var/mnt/data = var-mnt-data.mount)
  # https://docs.fedoraproject.org/en-US/fedora-coreos/storage/#_configuring_nfs_mounts
  name    = "var-home-podmgr.mount"
  content = <<EOT
[Unit]
Description=Mount data disk
Before=local-fs.target

[Mount]
What=/dev/disk/by-partlabel/data
Where=/var/home/podmgr
Type=xfs
DirectoryMode=0700

[Install]
RequiredBy=local-fs.target
EOT
}

data "ignition_directory" "podmgr" {
  path = "/var/home/podmgr"
  mode = 448 # 700 -> 448
  uid  = 1001
  gid  = 1001
}

data "ignition_user" "admin" {
  name = "admin"
  uid  = 1002
  groups = [
    "wheel",
    "sudo"
  ]
  # to gen password hash
  # https://docs.fedoraproject.org/en-US/fedora-coreos/authentication/#_using_password_authentication
  password_hash = "$y$j9T$cDLwsV9ODTV31Dt4SuVGa.$FU0eRT9jawPhIV3IV24W7obZ3PaJuBCVp7C9upDCcgD"
  ssh_authorized_keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
  ]
}

data "ignition_user" "podmgr" {
  name          = "podmgr"
  uid           = 1001
  password_hash = "$y$j9T$I4IXP5reKRLKrkwuNjq071$yHlJulSZGzmyppGbdWHyFHw/D8Gl247J2J8P43UnQWA"
  ssh_authorized_keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
  ]
}

# https://docs.fedoraproject.org/en-US/fedora-coreos/sysconfig-network-configuration/#_disabling_automatic_configuration_of_ethernet_devices
data "ignition_file" "disable_dhcp" {
  path      = "/etc/NetworkManager/conf.d/noauto.conf"
  mode      = 420
  overwrite = true
  content {
    content = <<EOT
[main]
# Do not do automatic (DHCP/SLAAC) configuration on ethernet devices
# with no other matching connections.
no-auto-default=*
EOT
  }
}

# https://docs.fedoraproject.org/en-US/fedora-coreos/sysconfig-network-configuration/#_configuring_a_static_ip
data "ignition_file" "eth0" {
  count     = local.count
  path      = "/etc/NetworkManager/system-connections/eth0.nmconnection"
  mode      = 384
  overwrite = true
  content {
    content = <<EOT
[connection]
id=eth0
type=ethernet
interface-name=eth0

[ipv4]
method=manual
addresses=192.168.255.2${count.index + 0}
gateway=192.168.255.1
dns=192.168.255.1
EOT
  }
}

# https://github.com/coreos/fedora-coreos-tracker/issues/681
data "ignition_file" "rpms" {
  path = "/etc/systemd/system/rpm-ostree-install.service.d/rpms.conf"
  mode = 420 # oct 644
  content {
    content = <<EOT
[Service]
Environment=RPMS="cockpit-system cockpit-ostree cockpit-podman cockpit-networkmanager"
EOT
  }
}

data "ignition_systemd_unit" "rpm-ostree" {
  name    = "rpm-ostree-install.service"
  enabled = true
  content = <<EOT
[Unit]
Description=Layer additional rpms
Wants=network-online.target
After=network-online.target
# We run before `zincati.service` to avoid conflicting rpm-ostree transactions.
Before=zincati.service
ConditionPathExists=!/var/lib/%N.stamp
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/rpm-ostree install --apply-live --allow-inactive $RPMS
ExecStart=/bin/touch /var/lib/%N.stamp
[Install]
WantedBy=multi-user.target
EOT
}

# copy ignition file to remote
resource "local_file" "ignition" {
  count    = local.count
  content  = data.ignition_config.ignition[count.index].rendered
  filename = "ignition${count.index + 1}.json"
}

resource "null_resource" "remote" {
  count      = local.count
  depends_on = [local_file.ignition]
  triggers = {
    # https://discuss.hashicorp.com/t/terraform-null-resources-does-not-detect-changes-i-have-to-manually-do-taint-to-recreate-it/23443/3
    manifest_sha1 = sha1(jsonencode(data.ignition_config.ignition[count.index].rendered))
    vhd_dir       = var.vhd_dir
    vm_name       = local.count <= 1 ? "${var.vm_name}" : "${var.vm_name}${count.index + 1}"
    # https://github.com/Azure/caf-terraform-landingzones/blob/a54831d73c394be88508717677ed75ea9c0c535b/caf_solution/add-ons/terraform_cloud/terraform_cloud.tf#L2
    filename = local_file.ignition[count.index].filename
    host     = var.hyperv_host
    user     = var.hyperv_user
    password = sensitive(var.hyperv_password)
  }

  connection {
    type     = "winrm"
    host     = self.triggers.host
    user     = self.triggers.user
    password = self.triggers.password
    use_ntlm = true
    https    = true
    insecure = true
    timeout  = "20s"
  }
  # copy to remote
  provisioner "file" {
    source = local_file.ignition[count.index].filename
    # destination = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks\\${each.key}\\cloud-init.iso"
    destination = join("/", [
      "${self.triggers.vhd_dir}",
      "${self.triggers.vm_name}\\${self.triggers.filename}"
      ]
    )
  }

  # for destroy
  provisioner "remote-exec" {
    when = destroy
    inline = [<<-EOT
      Powershell -Command "$ignition_file=(Join-Path -Path '${self.triggers.vhd_dir}' -ChildPath '${self.triggers.vm_name}\${self.triggers.filename}'); if (Test-Path $ignition_file) { Remove-Item $ignition_file }"
    EOT
    ]
  }
}

module "hyperv_machine_instance" {
  source     = "../modules/hyperv_instance2"
  depends_on = [null_resource.remote]
  count      = local.count

  boot_disk = {
    path = join("\\", [
      var.vhd_dir,
      local.count <= 1 ? "${var.vm_name}" : "${var.vm_name}${count.index + 1}",
      join("", ["${var.vm_name}", ".vhdx"])
      ]
    )
    source = var.source_disk
  }

  boot_disk_drive = [
    {
      controller_type     = "Scsi"
      controller_number   = "0"
      controller_location = "0"
      path = join("\\", [
        var.vhd_dir,
        local.count <= 1 ? "${var.vm_name}" : "${var.vm_name}${count.index + 1}",
        join("", ["${var.vm_name}", ".vhdx"])
        ]
      )
    }
  ]

  additional_disk_drives = [
    {
      controller_type     = "Scsi"
      controller_number   = "0"
      controller_location = "2"
      path                = local.count <= 1 ? var.data_disk_path : var.data_disk_path[count.index]
    }
  ]

  vm_instance = {
    name                 = local.count <= 1 ? var.vm_name : "${var.vm_name}${count.index + 1}"
    checkpoint_type      = "Disabled"
    dynamic_memory       = true
    generation           = 2
    memory_maximum_bytes = 8191475712
    memory_minimum_bytes = 2147483648
    memory_startup_bytes = 2147483648
    notes                = "This VM instance is managed by terraform"
    processor_count      = 4
    state                = "Off"

    vm_firmware = {
      console_mode                    = "Default"
      enable_secure_boot              = "On"
      secure_boot_template            = "MicrosoftUEFICertificateAuthority"
      pause_after_boot_failure        = "Off"
      preferred_network_boot_protocol = "IPv4"
      boot_order = [
        {
          boot_type           = "HardDiskDrive"
          controller_number   = "0"
          controller_location = "0"
        },
      ]
    }

    vm_processor = {
      compatibility_for_migration_enabled               = false
      compatibility_for_older_operating_systems_enabled = false
      enable_host_resource_protection                   = false
      expose_virtualization_extensions                  = false
      hw_thread_count_per_core                          = 0
      maximum                                           = 100
      maximum_count_per_numa_node                       = 4
      maximum_count_per_numa_socket                     = 1
      relative_weight                                   = 100
      reserve                                           = 0
    }

    integration_services = {
      "Guest Service Interface" = true
      "Heartbeat"               = true
      "Key-Value Pair Exchange" = true
      "Shutdown"                = true
      "Time Synchronization"    = true
      "VSS"                     = true
    }

    network_adaptors = [
      {
        name        = "Internal Switch"
        switch_name = "Internal Switch"
      }
    ]

  }
}

resource "null_resource" "kvpctl" {
  depends_on = [module.hyperv_machine_instance]
  count      = local.count

  triggers = {
    # https://discuss.hashicorp.com/t/terraform-null-resources-does-not-detect-changes-i-have-to-manually-do-taint-to-recreate-it/23443/3
    manifest_sha1 = sha1(jsonencode(data.ignition_config.ignition[count.index].rendered))
    vhd_dir       = var.vhd_dir
    vm_name       = local.count <= 1 ? "${var.vm_name}" : "${var.vm_name}${count.index + 1}"
    # https://github.com/Azure/caf-terraform-landingzones/blob/a54831d73c394be88508717677ed75ea9c0c535b/caf_solution/add-ons/terraform_cloud/terraform_cloud.tf#L2
    filename = local_file.ignition[count.index].filename
    host     = var.hyperv_host
    user     = var.hyperv_user
    password = sensitive(var.hyperv_password)
  }

  connection {
    type     = "winrm"
    host     = self.triggers.host
    user     = self.triggers.user
    password = self.triggers.password
    use_ntlm = true
    https    = true
    insecure = true
    timeout  = "20s"
  }

  provisioner "remote-exec" {
    inline = [<<-EOT
      Powershell -Command "$ignitionFile=(Join-Path -Path '${self.triggers.vhd_dir}' -ChildPath '${self.triggers.vm_name}\${self.triggers.filename}'); kvpctl.exe ${var.vm_name} add-ign $ignitionFile"
    EOT
    ]
  }
}