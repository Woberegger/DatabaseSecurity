# das Folgende installiert "docker" als Container-Plattform, optional kann man auch "podman" verwenden, die Syntax ist meist ident
sudo -s
snap install docker

# Für die Übungen verwenden wir Postgres und Oracle, folgende Scripts installieren und testen die beiden Container
01c_docker_postgres.md
01d_docker_oracle.md