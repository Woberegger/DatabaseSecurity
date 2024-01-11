export DOCKER_CONTAINERNAME=<MyContainerName> # z.B. Oracle23Free
docker stop $DOCKER_CONTAINERNAME
docker commit $DOCKER_CONTAINERNAME <ImageName> # z.B. docker commit $DOCKER_CONTAINERNAME oracle23c:backup
# das originale Image sollte bestehen bleiben, besser also neuen Namen für das backup finden
# und dann kann man vom neuen Image einen neuen container erstellen oder den existierenden ersetzen,
# wie im folgenden Beispiel und dann z.B. mit neuen geänderten Parametern (z.B. Portmapping) neu hochstarten
docker container rm $DOCKER_CONTAINERNAME
docker run ...  
