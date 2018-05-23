#!/bin/bash
# This script will create a systemd service to run sshtunnel in the background with bridge machine.

SERVICE_NAME=sshbridge.service
SYSTEMD_DIR=/etc/systemd/system

echo 'Enter your bridge (ec2, linode) host/ip address:'
read master_host; if [[ -z "$master_host" ]]; then echo "master host required"; exit 64; fi

echo 'Enter your master (ec2, linode) username:'
read username; if [[ -z "$username" ]]; then username=ubuntu; fi

echo 'Enter ssh port (default 22)':
read ssh_port; if [[ -z "$ssh_port" ]]; then ssh_port=22; fi

echo 'Enter port number for tunneling (default 10022)'
read tunnel_port; if [[ -z "$tunnel_port" ]]; then tunnel_port=10022; fi

echo 'Enter absolute path for identity file'
read identity_file; if [[ -z "$identity_file" ]]; then echo "identity file required for service setup. You may still use sshtunnel.sh script directly."; exit 64; fi

args=("-M 0")
args+=("-l $username")
args+=("-i $identity_file")
args+=("-NR $tunnel_port:localhost:$ssh_port")
args+=("-o \"StrictHostKeyChecking no\"")
args+=("-o \"UserKnownHostsfile /dev/null\"")
args+=("-o \"ServerAliveInterval 30\"")
args+=("-o \"ServerAliveCountMax 3\"")
args+=("-o \"ExitOnForwardFailure yes\"")
args+=("$master_host")

cmd_args="${args[@]}"

# install autossh
if hash autossh >/dev/null; then
    echo "autossh detected"
else
    echo "Installing autossh"
    sudo apt-get --assume-yes install autossh
    echo "autossh installed"
fi

# create systemd file
if sudo bash -c "cat > $SYSTEMD_DIR/$SERVICE_NAME <<EOF
[Unit]
Description=SSH Tunnel for behind the router Access using a bridge machine
After=network.target

[Service]
Environment="AUTOSSH_GATETIME=0"
ExecStart=/usr/bin/autossh $cmd_args

[Install]
WantedBy=multi-user.target
EOF"
>/dev/null; then
    echo "${SERVICE_NAME%.*} created [ok]"
else
    exit 64
fi
