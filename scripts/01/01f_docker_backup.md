# DBSec01 - docker container backup

**!!! only to be executed, when you really need it !!!**

this creates an image of an existing container:
Possible use case: You want to make additional ports visible or want to change other `docker run` parameters

```bash
export DOCKER_CONTAINERNAME=<MyContainerName> # e.g. OracleFree
$CONTAINERCMD stop $DOCKER_CONTAINERNAME
$CONTAINERCMD commit $DOCKER_CONTAINERNAME <ImageName>
# e.g. docker commit OracleFree oracle:backup
```

the original image should remain, so better use a new name for the backup.
Then you can create a new container from the created backup image (or replace the existing container),
as shown in the following example (pass updated parameters to `docker run` according to your requirements.
```bash
$CONTAINERCMD container rm <MyContainerName> # e.g. OracleFree
$CONTAINERCMD run ... 
```
