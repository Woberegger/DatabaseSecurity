# DBSec06 - how to use yum installer (and tcpdump) inside of docker image

```bash
echo -n "" >  /etc/yum/vars/ociregion
yum clean all
yum install tcpdump
```