# HCL requires Packer v1.5+

packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.1-dev"
      source  = "github.com/hashicorp/amazon"
    }
  }
}


variable "checksum" {
  type    = string
  default = "087a5743dc6fd6706d9b961b8147423ddc029451b938364c760d75440eb7be14"
}

variable "image_name" {
  type    = string
  default = "packer-hashistack"
}

variable "url" {
  type    = string
  default = "http://mirror.mhd.uk.as44574.net/mirror.centos.org/7.8.2003/isos/x86_64/CentOS-7-x86_64-DVD-2003.iso"
}

// Lookup the latest Amazon Linux AMI ID
data "amazon-ami" "amazonLinuxAMI" {
  most_recent = true
  owners = ["amazon"]
  filters = {
    virtualization-type = "hvm"
    root-device-type = "ebs"
    name = "amzn2-ami-minimal-selinux-enforcing-hvm-2*"
  }
}

source "amazon-ebs" "amazonLinuxLATEST" {
  ami_name      = "hashistackAmazonLATEST"
  instance_type = "t2.small"
  region        = "eu-west-1"
  source_ami    = data.amazon-ami.amazonLinuxAMI.id
  ssh_username  = "ec2-user"
  tags = {
    Base_AMI_Name = "{{ .SourceAMIName }}"
    OS_Version    = "Amazon Linux"
  }
  # use_vault_aws_engine = true
}

source "azure-arm" "autogenerated_2" {
  image_offer                       = "CentOS"
  image_publisher                   = "Red Hat"
  image_sku                         = "RHEL8-[TODO]"
  location                          = "West EU"
  managed_image_name                = "${var.image_name}"
  managed_image_resource_group_name = "packer"
  os_type                           = "Linux"
  vm_size                           = "Standard_DS2_v2"
}

source "digitalocean" "autogenerated_3" {
  api_token    = "YOUR API KEY"
  image        = "ubuntu-16-04-x64"
  region       = "nyc3"
  size         = "512mb"
  ssh_username = "root"
}

source "googlecompute" "autogenerated_4" {
  communicator = "ssh"
  disk_size    = 100
  disk_type    = "pd-standard"
  image_name   = "${var.image_name}"
  machine_type = "n1-standard-1"
  metadata = {
    block-project-ssh-keys = "false"
    enable-oslogin         = "false"
    ssh-keys               = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqqGVBss/FjzbDQ1zC8iFt0+vh4ePk0VODEhWaXdTO7c+HCcdlXnEZjvbXdFjJkpzvn+AzalS/T+7he8VoeJa5MAZdBU8ndZXn+CDhz3AVV7gGAx3BmcJFI2gWL/UrHssbsEzCu9MK7uKg+cHsH4gZmBcyiP70mg2Jc6fEQHi1rT0yKOy8TUpwLkp4i47cxzXMKQ3aCdOWlIa0uyZC8vLkEJIRATCN470IGPPN50JAnQgy0W1Gg4RXEVsrjvggepOIlbTp8vIfAF63KuDu374CUDjHafxHCJEfklfmpZNtZcc3AHXMw7NFa9niSLo/yZLC/Bv9SJa3YCjvK+93vTof jboero@z600.johnnyb"
  }
  project_id              = "gb-playground"
  source_image            = "rhel-8-v20210316"
  source_image_family     = "rhel-8"
  source_image_project_id = ["rhel-cloud"]
  ssh_timeout             = "20m"
  ssh_username            = "rhel"
  state_timeout           = "20m"
  #vault_gcp_oauth_engine  = "gcp/token/packer"
  zone                    = "europe-west4-a"
}

source "qemu" "qemu" {
  accelerator       = "kvm"
  boot_command      = ["<esc><wait>", "vmlinuz initrd=initrd.img ", "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks-centos8streams.cfg", "<enter>"]
  boot_key_interval = "1ms"
  boot_wait         = "1s"
  cpus              = 8
  disk_interface    = "virtio"
  disk_size         = "100G"
  format            = "qcow2"
  headless          = false
  http_directory    = "http"
  iso_checksum      = "${var.checksum}"
  iso_url           = "${var.url}"
  memory            = 8192
  net_device        = "virtio-net"
  shutdown_command  = "shutdown -P now"
  ssh_password      = "packer"
  ssh_timeout       = "20m"
  ssh_username      = "root"
  vm_name           = "${var.image_name}.qcow2"
}

source "virtualbox-iso" "vbox" {
  boot_command            = ["<esc><wait>", "vmlinuz initrd=initrd.img ", "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks-centos8streams.cfg", "<enter>"]
  boot_wait               = "4s"
  communicator            = "ssh"
  cpus                    = 8
  disk_size               = 100000
  guest_additions_mode    = "attach"
  guest_additions_sha256  = "62a0c6715bee164817a6f58858dec1d60f01fd0ae00a377a75bbf885ddbd0a61"
  guest_additions_url     = "https://download.virtualbox.org/virtualbox/6.1.10/VBoxGuestAdditions_6.1.10.iso"
  guest_os_type           = "RedHat_64"
  headless                = true
  http_directory          = "http"
  iso_checksum            = "${var.checksum}"
  iso_url                 = "${var.url}"
  memory                  = 8192
  output_filename         = "${var.image_name}.ovf"
  pause_before_connecting = "10s"
  shutdown_command        = "shutdown -P now"
  ssh_password            = "packer"
  ssh_timeout             = "15m"
  ssh_username            = "root"
  vm_name                 = "${var.image_name}"
}

/*
source "vmware-iso" "autogenerated_7" {
  boot_command      = ["<esc><wait>", "vmlinuz initrd=initrd.img ", "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks-centos8streams.cfg", "<enter>"]
  boot_key_interval = "1ms"
  boot_wait         = "1s"
  cpus              = 8
  disk_size         = "100G"
  iso_checksum      = "${var.checksum}"
  iso_checksum_type = "sha256"
  iso_url           = "${var.url}"
  memory            = 8192
  shutdown_command  = "shutdown -P now"
  ssh_password      = "packer"
  ssh_username      = "packer"
}
*/

build {
  #sources = ["source.amazon-ebs.autogenerated_1", "source.azure-arm.autogenerated_2", "source.digitalocean.autogenerated_3", "source.googlecompute.autogenerated_4", "source.qemu.autogenerated_5", "source.virtualbox-iso.autogenerated_6", "source.vmware-iso.autogenerated_7"]
  #sources = ["source.googlecompute.autogenerated_4"]
  #sources = ["source.virtualbox-iso.vbox", "source.qemu.qemu"]
  sources = ["source.amazon-ebs.amazonLinuxLATEST"]
  
  provisioner "file" {
    destination = "/tmp/replicated.conf"
    direction   = "upload"
    source      = "./http/replicated.conf"
  }

  provisioner "file" {
    destination = "/tmp/answers"
    direction   = "upload"
    source      = "./http/answers"
  }

  provisioner "file" {
    destination = "/tmp/crontab"
    direction   = "upload"
    source      = "./http/crontab"
  }

  provisioner "file" {
    destination = "/tmp/install.sh"
    direction   = "upload"
    source      = "./http/install.sh"
  }

  provisioner "file" {
    destination = "/tmp/replicated.sh"
    direction   = "upload"
    source      = "./http/replicated.sh"
  }

  provisioner "file" {
    destination = "/tmp/replicated.json"
    direction   = "upload"
    source      = "./http/replicated.json"
  }

  provisioner "shell" {
    inline = ["sudo bash -x /tmp/install.sh"]
  }

  # HCP Support experimental.
  # Use env variables HCP_CLIENT_ID, HCP_CLIENT_SECRET
  /*
  hcp_packer_registry {
    slug        = "hashistack-el"
    description = "Some nice description about the image which artifact is being published to HCP Packer Registry. =D"

    labels = {
      "version" = "1.2.0"
    }
  }
  */

}
