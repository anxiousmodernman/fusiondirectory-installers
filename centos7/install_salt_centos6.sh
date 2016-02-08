#!/bin/bash

# Fusion Directory Installation script for Centos7
# Based on instructions available here: https://www.fusiondirectory.org/redhat/

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


# Get the GPG key
gpg --keyserver keys.gnupg.net --recv-key 62B4981F 
gpg --export -a "Fusiondirectory Archive Manager <contact@fusiondirectory.org>" > FD-archive-key
cp FD-archive-key /etc/pki/rpm-gpg/RPM-GPG-KEY-FUSIONDIRECTORY
rpm --import  /etc/pki/rpm-gpg/RPM-GPG-KEY-FUSIONDIRECTORY

# Write the repo config file
cat >/etc/yum.repos.d/saltstack.repo <<EOL
[fusiondirectory]
name=Fusiondirectory Packages for RHEL / CentOS 7
baseurl=http://repos.fusiondirectory.org/rhel7/RPMS/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-FUSIONDIRECTORY

[fusiondirectory-extra]
name=Fusiondirectory Extra Packages for RHEL / CentOS 7
baseurl=http://repos.fusiondirectory.org/rhel7-rpm-extra/RPMS
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-FUSIONDIRECTORY
EOL

# Begin the install
yum clean expire-cache
yum update -y
yum install -y epel-release
yum install -y fusiondirectory
yum install -y fusiondirectory-schema schema2ldif

# 
fusiondirectory-insert-schema
service httpd restart

