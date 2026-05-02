#!/bin/bash

set -ouex pipefail

### Install packages

# this installs packages from fedora repos
dnf5 install -y atuin distrobox gdu just mosh nmap-ncat node-exporter qemu-guest-agent tmux uv

# install MongoDB shell
dnf5 install -y https://repo.mongodb.org/yum/redhat/9Server/mongodb-org/8.2/x86_64/RPMS/mongodb-mongosh-2.5.9.x86_64.rpm

# deploy system configuration files
rsync -rvK /ctx/files/etc/ /etc/
rsync -rvK /ctx/files/usr/ /usr/

## deploy SumoLogic collector quadlet
adduser sumologic
mkdir -p /var/lib/systemd/linger
touch /var/lib/systemd/linger/sumologic
chmod 0644 /var/lib/systemd/linger/sumologic
mkdir -p /usr/share/containers/users/$(id -u sumologic)
rsync -rvK /ctx/files/collector.container /usr/share/containers/users/$(id -u sumologic)/

#### Enable System Unit Files

systemctl enable tailscaled.service
systemctl enable prometheus-node-exporter.service
systemctl enable journal_syslog.service
