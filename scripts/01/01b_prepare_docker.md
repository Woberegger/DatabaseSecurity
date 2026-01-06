# DBSec01 - install docker

das Folgende installiert "docker" als Container-Plattform, optional kann man auch "podman" verwenden, die Syntax ist meist ident
```bash
sudo -s
type docker # check, if docker is already installed
if [ $? -gt 0 ]; then
   snap install docker
   # eventuell nötig, manuell zu starten
   systemctl start snap.docker.dockerd # siehe Files in /etc/systemd/system
fi
```
WICHTIG: AppArmor kann so konfiguriert sein, dass es "docker stop" ablehnt, dazu das File [](https://github.com/Woberegger/DatabaseSecurity/blob/main/scripts/01/docker) wie in Zeile1
         des Config File "docker" beschrieben auf der OpenStack-VM ablegen und aktivieren

```bash
sudo -s
# copy this file to /etc/apparmor.d directory and call
apparmor_parser -r /etc/apparmor.d/docker
```

Für die Übungen verwenden wir Postgres und Oracle, folgende Scripts installieren und testen die beiden Container
* 01c_docker_postgres.md
* 01d_docker_oracle.md
* zusätzlich weitere container z.B. für pgadmin und cloudbeaver installieren (wenn Zeit)