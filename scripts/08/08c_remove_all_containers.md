# DBSec08 - Postgres cluster removal

execute following, when you want to start from scratch and recreate all
```bash
cd ~student/DatabaseSecurity/scripts/08/docker_cluster/
$CONTAINERCMD-compose down pg-replica2
$CONTAINERCMD-compose down pg-replica1
$CONTAINERCMD-compose down pg-primary
$CONTAINERCMD ps -a
$CONTAINERCMD container stop pg-replica2
$CONTAINERCMD container stop pg-replica1
$CONTAINERCMD container stop pg-primary
$CONTAINERCMD container rm pg-replica2
$CONTAINERCMD container rm pg-replica1
$CONTAINERCMD container rm pg-primary
$CONTAINERCMD volume ls
$CONTAINERCMD volume rm docker_cluster_replica2-data docker_cluster_replica1-data docker_cluster_primary-data
$CONTAINERCMD image rm localhost/docker_cluster_replica2 localhost/docker_cluster_replica1  localhost/docker_cluster_primary
$CONTAINERCMD images
```