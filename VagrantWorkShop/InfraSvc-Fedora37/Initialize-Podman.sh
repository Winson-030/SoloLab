# Start Podman’s API so that Cockpit can interact with it
sudo systemctl enable --now podman.socket

# Enable CPU or CPUSET limit delegation for all users
sudo mkdir -p /etc/systemd/system/user@.service.d
sudo sh -c "cat >/etc/systemd/system/user@.service.d/delegate.conf<<EOF
[Service]
Delegate=memory pids cpu cpuset
EOF"

# Low down the unprivileged port
sudo sh -c "echo 'net.ipv4.ip_unprivileged_port_start=53'>>/etc/sysctl.conf"

# Enable memlock for all users
sudo sh -c "cat >>/etc/security/limits.conf<<EOF
*                hard    memlock         -1
*                soft    memlock         -1
EOF"

# Enable lingering
loginctl enable-linger vagrant