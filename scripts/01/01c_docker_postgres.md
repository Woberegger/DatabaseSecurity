# DBSec01 - install postgres

Postgres container download and first test by creating a user and a database, then login to the container with psql commandline tool.

```bash
$CONTAINERCMD pull postgres
export DOCKER_CONTAINERNAME=Postgres
```

that the individual containers can communicate with each other, we have to put them in the same virtual network
please use the same IP-Range and Gateway, so that it is easier to share the statements
```bash
export NETWORK=my-docker-network
$CONTAINERCMD network create --driver=bridge --subnet=172.20.19.0/24 --ip-range=172.20.19.0/24 --gateway=172.20.19.1 $NETWORK
```

additionally we set environment variable "-e POSTGRES_USER=postgres", that this is the user, under which the database is created and we log in
```bash
$CONTAINERCMD run --name $DOCKER_CONTAINERNAME --network ${NETWORK} -p 5432:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=my-secret-pw -d postgres:latest
```

interactive login via `bash` or `psql` command line into the running container
by setting `--tty=false` we can pass a set of commands as `Here-Document` to the script
```bash
$CONTAINERCMD exec -i --tty=false -u postgres ${DOCKER_CONTAINERNAME} psql <<!
   CREATE ROLE scott LOGIN PASSWORD 'FhIms9999';
   CREATE DATABASE ims 
   WITH 
      ENCODING = 'UTF8'
      OWNER = scott
      CONNECTION LIMIT = 100;
   \c ims
!
```

later, when container was shut down, you can use the following to start again and re-login to the container:
(in that case we use `-it` to get an interactive terminal

```bash
$CONTAINERCMD start Postgres
sleep 3 # give the container some time to start up
$CONTAINERCMD exec -it -u postgres Postgres psql
```

if later you need to change something in the network configuration, you can re-connect to that network:
```bash
$CONTAINERCMD network connect my-docker-network Postgres
```