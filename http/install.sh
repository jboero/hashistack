#!/bin/bash -x
cd /root
setenforce 0
mv /tmp/replicated.conf /etc

# COPR repo version (open source)
#yes | dnf copr enable boeroboy/hashicorp

# Hashicorp official repo
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

# For EL8:
#yes | dnf -y install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm
#dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
#yes | dnf install -y docker-ce-3:19.03.11-3.el7 packer consul vault nomad terraform --nobest

# Packer requires COPR release.
yes | dnf install -y docker consul-enterprise vault-enterprise nomad-enterprise

crontab /tmp/crontab

# Settings for Terraform Enterprise:
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
# Flush all firewall rules to start fresh
iptables -F
iptables-save
firewall-cmd --permanent --zone=trusted --add-interface=docker0
firewall-cmd --zone=public --permanent --add-port=4600-4700/tcp
firewall-cmd --zone=public --permanent --add-port=8300-8800/tcp
firewall-cmd --zone=public --permanent --add-port=443/tcp
firewall-cmd --reload
systemctl enable --now docker
sed -E -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
curl -sSL -o /tmp/replicated.sh -o install.sh https://get.replicated.com/docker
chmod +x /tmp/replicated.sh
/tmp/replicated.sh < /tmp/answers
