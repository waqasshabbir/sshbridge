## SSH Bridge

Creates a systemd service on the host machine to make it accessible over SSH through a bridge machine.

### Usage

To install service

```
   sudo bash setup.sh
```

Provide parameters required by the script on the command prompt.

Once the service is installed. Activate it as following:

```
   sudo systemctl start sshbridge
```

You can check the status of service as follows:

```
   sudo systemctl status sshtunnel
```

On the bridge machine, to ssh into the host running this service, use the following command:

```
   ssh -p <tunnel_port> localhost -l <host_machine_user>
```

### Dependencies

[autossh](https://linux.die.net/man/1/autossh)

### Common problems and fixes

In some instances, port 22 may not be open. Or openssh-server may not be installed. Make sure both requirements are satisfied on the host machine.
