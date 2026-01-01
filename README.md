# Rocky Linux 10 – Vagrant Box (libvirt)

This repository builds a **minimal Rocky Linux 10 Vagrant box** using **Packer**, **Kickstart**, and **QEMU/KVM (libvirt)** for vagrant to test few things.

The image is built from the official Rocky Linux ISO and is designed as a **golden image** for DevOps labs and infrastructure-as-code workflows.

## Key points

* Fully unattended installation via Kickstart
* Minimal `@core` Rocky Linux system
* SSH + `vagrant` user with passwordless sudo
* Cleaned and reproducible image
* Exported as a Vagrant box for libvirt

## Build

```bash
packer init .
packer build .
```

## Use with Vagrant

```bash
vagrant box add rockylinux-10-basic-libvirt.box --name rockylinux10
vagrant init rockylinux10
vagrant up --provider=libvirt
```
