#!/bin/bash

# Disable Transparent Huge Pages (THP)
echo 'Disabling Transparent Huge Pages (THP)...'
echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled
echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag

# Make the changes permanent
cat <<EOF > /etc/systemd/system/disable-thp.service
[Unit]
Description=Disable Transparent Huge Pages (THP)
After=sysinit.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled'
ExecStart=/bin/sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/defrag'

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable disable-thp
systemctl start disable-thp

# Set swappiness to 1
echo 'Setting swappiness to 1...'
sysctl vm.swappiness=1

# Make the change permanent
if grep -q 'vm.swappiness' /etc/sysctl.conf; then
    sed -i 's/^vm.swappiness=.*$/vm.swappiness=1/' /etc/sysctl.conf
else
    echo 'vm.swappiness=1' >> /etc/sysctl.conf
fi

echo 'Changes have been applied. Please reboot the system to ensure all settings take effect.'
