# DBSec06 - how to use yum installer (and tcpdump) inside of Redhat-based docker/podman image

*ATTENTION* This seems to hang in our OracleFree image, so DO NOT do this there!
```bash
echo -n "" >  /etc/yum/vars/ociregion
yum clean all
yum install tcpdump
```