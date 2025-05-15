#!/bin/bash

set -e

# Prompt for username and password
read -p "Enter the username to create for Samba and system access: " USERNAME
echo "Enter a password for user '$USERNAME' (used for system and Samba):"
read -s PASSWORD

# Install required packages
sudo apt update
sudo apt install -y samba samba-common-bin avahi-daemon

# Create user and set password
sudo useradd -m "$USERNAME" || echo "User '$USERNAME' already exists"
echo "$USERNAME:$PASSWORD" | sudo chpasswd
(echo "$PASSWORD"; echo "$PASSWORD") | sudo smbpasswd -a "$USERNAME"

# Create directories
sudo mkdir -p /mnt/samsung/timemachine
sudo mkdir -p /mnt/samsung/shared

# Set ownership and permissions
sudo chown -R "$USERNAME:$USERNAME" /mnt/samsung/timemachine
sudo chown -R "$USERNAME:$USERNAME" /mnt/samsung/shared
sudo chmod -R 770 /mnt/samsung/timemachine
sudo chmod -R 775 /mnt/samsung/shared

# Backup and update Samba config
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

cat <<EOL | sudo tee -a /etc/samba/smb.conf

[timemachine]
   path = /mnt/samsung/timemachine
   valid users = $USERNAME
   writeable = yes
   browsable = yes
   guest ok = no
   create mask = 0660
   directory mask = 0770
   vfs objects = catia fruit streams_xattr
   fruit:resource = xattr
   fruit:metadata = stream
   fruit:locking = none
   fruit:time machine = yes
   fruit:time machine max size = 500G

[shared]
   path = /mnt/samsung/shared
   valid users = $USERNAME
   writeable = yes
   browsable = yes
   guest ok = no
   create mask = 0664
   directory mask = 0775
EOL

# Restart Samba
sudo systemctl restart smbd

echo "✅ Setup complete. Use '$USERNAME' to connect from macOS."
