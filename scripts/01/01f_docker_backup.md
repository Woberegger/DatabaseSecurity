# DBSec01 - docker container backup

**!!! nur bei Bedarf auszuführen !!!**

hierbei wird ein neues Image von einem existierenden Container erstellt:
Anwendungszweck z.B., wenn man zusätzliche Ports freigeben will oder andere "docker run" Paramater verändern will

```bash
export DOCKER_CONTAINERNAME=<MyContainerName> # z.B. OracleFree
$CONTAINERCMD stop $DOCKER_CONTAINERNAME
$CONTAINERCMD commit $DOCKER_CONTAINERNAME <ImageName>
# z.B. docker commit OracleFree oracle:backup
```

das originale Image sollte bestehen bleiben, besser also neuen Namen für das backup finden
undd dann kann man vom neuen Image einen neuen container erstellen oder den existierenden ersetzen,
wie im folgenden Beispiel und dann z.B. mit neuen geänderten Parametern (z.B. Portmapping) neu hochstarten
```bash
$CONTAINERCMD container rm <MyContainerName> # z.B. OracleFree
$CONTAINERCMD run ... 
```
