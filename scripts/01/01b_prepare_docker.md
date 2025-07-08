# das Folgende installiert "docker" als Container-Plattform, optional kann man auch "podman" verwenden, die Syntax ist meist ident
sudo -s
type docker # check, if docker is already installed
if [ $? -gt 0 ]; then
   snap install docker
   # eventuell nötig, manuell zu starten
   systemctl start snap.docker.dockerd # siehe Files in /etc/systemd/system
fi
# WICHTIG: AppArmor kann so konfiguriert sein, dass es "docker stop" ablehnt, dazu das File "docker" wie in Zeile1
# des Config File "docker" beschrieben ablegen und aktivieren

# Für die Übungen verwenden wir Postgres und Oracle, folgende Scripts installieren und testen die beiden Container
01c_docker_postgres.md
01d_docker_oracle.md
# zusätzlich weitere container z.B. für pgadmin und cloudbeaver installieren
