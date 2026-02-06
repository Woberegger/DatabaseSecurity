# DBSec01 - install docker

the following installs "docker" or "podman", syntax is more or less identical, but "podman" is more secure and does not require root privileges
```bash
sudo -s
   # this differs between Debian-based and RedHat-based Linux distributions, on RedHat we use podman instead of docker (https://podman.io/)
   if [ -f /etc/redhat-release ]; then
      type podman # check, if podman is already installed
      if [ $? -gt 0 ]; then
         yum install -y podman
      fi
      # maybe manual start is needed - see files in /etc/systemd/system
      systemctl enable podman
      systemctl start podman
   else
      type docker # check, if docker is already installed
      if [ $? -gt 0 ]; then
         snap install docker
      fi
      # maybe manual start is needed - see files in /etc/systemd/system
      systemctl enable snap.docker.dockerd
      systemctl start snap.docker.dockerd 
   fi
fi
```
**IMPORTANT**: On Debian/Ubuntu AppArmor can be configured, that it rejects "docker stop".
   For that purpose copy this file  [](https://github.com/Woberegger/DatabaseSecurity/blob/main/scripts/01/docker)
   to the openstack platform with command, as described in line 1 of the script:

```bash
sudo -s
# copy this file to /etc/apparmor.d directory and call
apparmor_parser -r /etc/apparmor.d/docker
```

For the exercises we will use Docker/Podman containers, which are a kind of "lightweight virtual machines".
We use Postgres, Oracle and MongoDB, the following scripts install and test the respective containers:

* 01c_docker_postgres.md
* 01d_docker_oracle.md
* additionally install containers for pgadmin and cloudbeaver