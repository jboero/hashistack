# Hashistack - Packer build on EL7/8
Complete Hashistack including Terraform, Consul, Vault, Nomad, Packer, Terraform Enterprise Replicated base all in a single packer manifest.  Builds in parallel on Qemu, VirtualBox, GCP, AWS, and Azure using CentOS 8 Streams base image.  Vault is used for build credentials where possible.

This is built in parallel on CentOS 8 Streams using Packer and acquiring cloud credentials from Vault which you need to configure.  Hashicorp open source RPMs are installed with DNF and will receive updates after deployed.  Terraform Enterprise is installed (partially) to the point where you can just add your Replicated license to deploy TFE.

The image is pre-configured to automatically update the OS and all Hashicorp products every night.  Terraform Enterprise will update automatically or manually based on the license file you give it.

Note that Replicated still doesn't seem to support RHEL 8 (Docker) so I will default this to RHEL 7 if/until it does.
