# das Folgende installiert "docker" als Container-Plattform, optional kann man auch "podman" verwenden, die Syntax ist meist ident
sudo -s
type docker # check, if docker is already installed
if [ $? -gt 0 ]; then
   snap install docker
fi

# Für die Übungen verwenden wir Postgres und Oracle, folgende Scripts installieren und testen die beiden Container
01c_docker_postgres.md
01d_docker_oracle.md
