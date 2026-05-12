# DBSec08 - Postgres cluster removal

execute following, when you want to start from scratch and recreate all
```bash
cd ~student/DatabaseSecurity/scripts/08/docker_cluster/
podman-compose down pg-replica2
podman-compose down pg-replica1
podman-compose down pg-primary
podman ps -a
podman container rm pg-replica2
podman container rm pg-replica1
podman container rm pg-primary
podman volume ls
podman volume rm docker_cluster_replica2-data docker_cluster_replica1-data docker_cluster_primary-data
podman image rm localhost/docker_cluster_replica2 localhost/docker_cluster_replica1  localhost/docker_cluster_primary
podman images
```