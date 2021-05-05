#!/bin/bash -x
mv /tmp/replicated.conf /etc

# For EL8 with Docker:
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Full stack
sudo dnf install -y terraform vault consul nomad boundary waypoint

# Uncomment remaining packages as needed.
yes | dnf install -y docker-ce # packer consul vault nomad terraform
systemctl enable --now docker

crontab /tmp/crontab

# Try not to disable SELinux
#sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config

# Flush all firewall rules to start fresh
#iptables -F
#iptables-save
#firewall-cmd --permanent --zone=trusted --add-interface=docker0
#firewall-cmd --zone=public --permanent --add-port=4600-4700/tcp
#firewall-cmd --zone=public --permanent --add-port=8300-8700/tcp
firewall-cmd --zone=public --permanent --add-port=8800/tcp
firewall-cmd --zone=public --permanent --add-port=443/tcp
firewall-cmd --reload

sed -E -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

curl -sSL -o /tmp/replicated.sh https://install.terraform.io/ptfe/stable
#curl -sSL -o /tmp/replicated.sh -o install.sh https://get.replicated.com/docker

#/tmp/replicated.sh < /tmp/answers
export privip=$(ip a show dev eth0 | awk '/inet / {print $2}' |cut -d/ -f1)
bash -x /tmp/replicated.sh no-proxy no-docker \
    public-address="$privip" private-address="$privip" \
    bypass-firewalld-warning 

