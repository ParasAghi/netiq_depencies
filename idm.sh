#!/bin/bash

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Get local IP address excluding loopback and non-eth interfaces
LOCAL_IP=$(ip -4 addr show | grep -v "127.0.0.1" | grep -v "inet6" | grep -oP "(?<=inet\s)\d+(\.\d+){3}" | head -n 1)

# Check if local IP was detected
if [[ -z "$LOCAL_IP" ]]; then
    echo "Error: Unable to detect a local IP address."
    exit 1
fi

# Get the fully qualified domain name (FQDN)
FQDN=$(hostname --fqdn 2>/dev/null)

# Check if FQDN was detected
if [[ -z "$FQDN" ]]; then
    echo "Error: Unable to detect FQDN."
    exit 1
fi

# Replace existing entry in /etc/hosts if the IP already exists
if grep -q "$LOCAL_IP" /etc/hosts; then
    echo "An entry for IP $LOCAL_IP already exists in /etc/hosts. Replacing it."
    # Remove the old entry
    sed -i "/$LOCAL_IP/d" /etc/hosts
fi

# Add the new entry to /etc/hosts
echo "$LOCAL_IP $FQDN" >> /etc/hosts
echo "Host entry added to /etc/hosts: $LOCAL_IP $FQDN"

# File to be modified for SELinux
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
  echo -e "manankharbanda30@gmail.com\nNovell@12345678" | sudo subscription-manager register --username=rahultest12126@gmail.com --password=Novell@12345678
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

# Reboot notification for SELinux changes
echo "Please reboot the system for SELinux changes to take effect."

# Install necessary packages
yum install bc lsof ksh yum-utils createrepo unzip zip net-tools libgcc*.i686 libncurses* ncurses-libs chkconfig iproute nmap initscripts -y
yum install libXtst-*.i686 libXrender-*.i686 libXi-*.i686 glibc-*.i686 libgcc-*.i686 gettext libXau.i686 libxcb.i686 libstdc++ libnsl* libnsl*.i686 libX11.i686 libXext.i686 -y
yum install openldap* -y
timedatectl set-ntp true
systemctl restart chronyd
# Disable and stop firewalld
systemctl stop firewalld
systemctl disable firewalld
systemctl mask firewalld

echo "Please reboot and recheck hostentry."

cat /etc/hosts
