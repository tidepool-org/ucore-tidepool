#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y atuin distrobox gdu just mosh tmux uv

# install SumoLogic collector
# ref: https://developers.redhat.com/articles/2025/09/23/customize-rhel-coreos-on-cluster-image-mode#key_concept__the__var_limitation
mkdir /var/opt
echo 'g sumologic_collector' > /usr/lib/sysusers.d/sumocollector.conf
dnf5 install -y https://download-collector.us2.sumologic.com/rest/download/rpm/64
mv /var/opt/SumoCollector /usr/lib/SumoCollector
echo 'L /opt/SumoCollector - - - - /usr/lib/SumoCollector' > /usr/lib/tmpfiles.d/SumoCollector.conf

# install MongoDB shell
dnf5 install -y https://repo.mongodb.org/yum/redhat/9Server/mongodb-org/8.2/x86_64/RPMS/mongodb-mongosh-2.5.9.x86_64.rpm

# deploy system configuration files
rsync -rvK /ctx/files/etc/ /etc/

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

#systemctl enable podman.socket
systemctl enable collector.service
