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

# Verify SELinux changes
if grep -q '^SELINUX=disabled' "$SELINUX_CONFIG"; then
  echo "SELinux has been disabled in $SELINUX_CONFIG."
else
  echo "Failed to disable SELinux. Please check the file manually."
  exit 1
fi

# Check RHEL subscription status
if ! subscription-manager status &>/dev/null; then
  echo "System is not subscribed. Registering the system..."
  
  # Register the system using echo and pipe to avoid user interaction
  echo -e "manankharbanda30@gmail.com\nNovell@12345678" | sudo subscription-manager register --username=manankharbanda30@gmail.com --password=Novell@12345678
  if [ $? -eq 0 ]; then
    echo "System successfully registered."
    
    # Automatically attach a subscription
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

yum install glibc*.i686


systemctl stop firewalld
systemctl disable firewalld
systemctl mask firewalld