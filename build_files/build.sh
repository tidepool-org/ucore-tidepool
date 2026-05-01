#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y atuin distrobox gdu just mosh node-exporter qemu-guest-agent tmux uv

# install MongoDB shell
dnf5 install -y https://repo.mongodb.org/yum/redhat/9Server/mongodb-org/8.2/x86_64/RPMS/mongodb-mongosh-2.5.9.x86_64.rpm

# deploy system configuration files
rsync -rvK /ctx/files/etc/ /etc/
rsync -rvK /ctx/files/usr/ /usr/

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

## deploy SumoLogic collector quadlet
adduser sumologic
touch /var/lib/systemd/linger/sumologic
chmod 0644 /var/lib/systemd/linger/sumologic
mkdir -p /home/sumologic/.config/containers/systemd
rsync -rvK /ctx/files/collector.container /home/sumologic/.config/containers/systemd/collector.container
chown -R sumologic:sumologic /home/sumologic/.config
echo 'net.ipv4.ip_unprivileged_port_start=514' > /etc/sysctl.d/50-sumologic.conf

#### Example for enabling a System Unit File

systemctl enable tailscaled.service
systemctl enable prometheus-node-exporter.service
systemctl enable journal_syslog.service
