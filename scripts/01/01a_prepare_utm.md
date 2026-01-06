# DBSec01 - prepare UTM

## Anleitung, um UTM Virtualisierung auf MAC OS zu verwenden

download über z.B. [](https://mac.getutm.app/)

Nachdem das CLI Interface über UTM es nicht zulässt, Copy + Paste mit Shift + Insert durchzuführen,
ist es am besten, sich einfach per SSH auf die VM zu connecten
den public SSH key kann man einfach mit folgendem Befehl auf die VM kopieren:
```bash
ssh-copy-id -i ~/.ssh/id_rsa <username>@<vm-ip>
```

Um gewisse ports (z.B. 1521) vom Rechner aus zu erreichen, muss man (als root user) die betreffenden Ports in der Firewall permitten
```bash
ufw allow 1521
```
