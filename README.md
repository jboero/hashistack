# Hashistack - Packer build on EL8
Complete Hashistack including TFE, Terraform, Consul, Vault, Nomad, Packer all in a single packer manifest.  Builds in parallel on Qemu, VirtualBox, GCP, AWS, Azure using CentOS 8 base image.

This is built in parallel on CentOS 8 Streams using Packer and acquiring cloud credentials from Vault which you need to configure.  Hashicorp open source RPMs are installed with DNF and will receive updates after deployed.  Terraform Enterprise is installed (partially) to the point where you can just add your Replicated license to deploy TFE.
