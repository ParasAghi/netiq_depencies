#!/bin/bash

# Check if the script is being run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# File to be modified
SELINUX_CONFIG="/etc/selinux/config"

# Backup the current SELinux config file
if [ -f "$SELINUX_CONFIG" ]; then
  cp "$SELINUX_CONFIG" "${SELINUX_CONFIG}.bak"
  echo "Backup created at ${SELINUX_CONFIG}.bak"
else
  echo "SELinux config file not found at $SELINUX_CONFIG."
  exit 1
fi

# Disable SELinux
sed -i 's/^SELINUX=.*/SELINUX=disabled/' "$SELINUX_CONFIG"

# Verify changes
if grep -q '^SELINUX=disabled' "$SELINUX_CONFIG"; then
  echo "SELinux has been disabled in $SELINUX_CONFIG."
else
  echo "Failed to disable SELinux. Please check the file manually."
  exit 1
fi

echo "Please reboot the system for changes to take effect."



yum install bc lsof ksh yum-utils createrepo unzip zip net-tools libgcc*.i686 libncurses* ncurses-libs chkconfig iproute initscripts -y

yum install libXtst-*.i686 libXrender-*.i686 libXi-*.i686  glibc-*.i686 libgcc-*.i686 gettext libXau.i686 libxcb.i686 libstdc++ libnsl* libnsl*.i686 libX11.i686 libXext.i686  -y

yum install openldap* -y


systemctl stop firewalld
systemctl disable firewalld
systemctl mask firewalld
