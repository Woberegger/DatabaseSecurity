# DBSec01 - prepare UTM

## Instructions for using UTM virtualization on macOS

Download from e.g. [](https://mac.getutm.app/)

Since the UTM CLI does not allow copy + paste with `Shift` + `Insert`, it is best to connect to the VM via SSH.
You can copy your public SSH key to the VM with the following command:

```bash
ssh-copy-id -i ~/.ssh/id_rsa <username>@<vm-ip>
```

To reach certain ports (e.g. 1521) from the host machine, you must allow the respective ports in the firewall (as root user):

```bash
ufw allow 1521
```