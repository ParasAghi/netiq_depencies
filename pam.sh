#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

SELINUX_CONFIG="/etc/selinux/config"

if [ -f "$SELINUX_CONFIG" ]; then
  cp "$SELINUX_CONFIG" "${SELINUX_CONFIG}.bak"
  echo "Backup created at ${SELINUX_CONFIG}.bak"
else
  echo "SELinux config file not found at $SELINUX_CONFIG."
  exit 1
fi

sed -i 's/^SELINUX=.*/SELINUX=disabled/' "$SELINUX_CONFIG"

if grep -q '^SELINUX=disabled' "$SELINUX_CONFIG"; then
  echo "SELinux has been disabled in $SELINUX_CONFIG."
else
  echo "Failed to disable SELinux. Please check the file manually."
  exit 1
fi

if ! subscription-manager status &>/dev/null; then
  echo "System is not subscribed. Registering the system..."
  
  echo -e "manankharbanda30@gmail.com\nNovell@12345678" | sudo subscription-manager register --username=manankharbanda30@gmail.com --password=Novell@12345678
  if [ $? -eq 0 ]; then
    echo "System successfully registered."
    
    sudo subscription-manager attach --auto
    echo "Subscription attached successfully."
  else
    echo "Failed to register the system. Please check your credentials."
    exit 1
  fi
else
  echo "System is already subscribed."
fi

echo "Please reboot the system for SELinux changes to take effect."

yum clean all

yum install glibc*.i686 nmap bc lsof ksh yum-utils createrepo unzip zip net-tools redhat-lsb


systemctl stop firewalld
systemctl disable firewalld
systemctl mask firewalld
