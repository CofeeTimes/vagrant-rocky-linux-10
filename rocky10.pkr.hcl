packer {
    required_plugins {
        qemu = {
            version = "~> 1"
            source = "github.com/hashicorp/qemu"
        }

        vagrant = {
            version = "~> 1"
            source = "github.com/hashicorp/vagrant"
        }
    }
}


variable "vm_name" {
  type = string
  default = "rockylinux-10-basic"
}

variable "cpu_model" {
    type = string
    default = "host"
}

variable "iso_path" {
    type = string
    default = "./Rocky-10.1-x86_64-minimal.iso"
}

variable "iso_checksum" {
    type = string
    default = "5aafc2c86e606428cd7c5802b0d28c220f34c181a57eefff2cc6f65214714499"
}

variable "ssh_username" {
  type    = string
  default = "vagrant"
}

variable "ssh_password" {
  type    = string
  default = "vagrant"
}


source "qemu" "rocky10" {
    vm_name = var.vm_name
    accelerator = "kvm"

    cpu_model = var.cpu_model

    cpus = 2
    memory = 2048

    disk_size = "20G"
    format = "qcow2"

    iso_url = var.iso_path
    iso_checksum = var.iso_checksum

    http_directory = "./http"

    boot_wait = "5s"
    boot_command = [
        "<up><wait>",
        "e<wait>",
        "<down><down><wait>",
        "<end>",
        " inst.text",
        " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg",
        " ip=dhcp",
        "<f10>"
    ]

    communicator = "ssh"
    ssh_username = var.ssh_username
    ssh_password = var.ssh_password
    ssh_timeout  = "300s"
    
    shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"
}


build {
    sources = ["source.qemu.rocky10"]

    provisioner "shell" {
        inline = [
            "echo 'vagrant' | sudo -S dnf -y update",
            "echo 'vagrant' | sudo -S dnf -y install vim qemu-guest-agent",
            "echo 'vagrant' | sudo -S systemctl enable qemu-guest-agent || true",

            "sudo dnf -y clean all || true",
            "sudo rm -rf /var/cache/dnf || true",
            "sudo rm -f /etc/ssh/ssh_host_* || true",
            "sudo truncate -s 0 /etc/machine-id ||true"
        ]
    }

    post-processor "vagrant" {
        provider_override = "libvirt"
        output = "${var.vm_name}-libvirt.box"
    }
}