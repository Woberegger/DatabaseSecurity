# DBSec01 - prepare WSL

## Anleitung, um ein frisches wsl (Windows Subsystem for Linux) vorzubereiten

Das geht schneller und einfacher als mit virtueller Maschine (VmWare, VirtualBox etc.)

Wir verwenden eine neue, frische Distro, damit eine ev. bereits installierte Distribution nicht beeinflusst wird
siehe z.B. Anleitung unter [](https://superuser.com/questions/1515246/how-to-add-second-wsl2-ubuntu-distro-fresh-install)

1. Download eines Tar-Archives, z.B. für Distro 24-04 (da dieses Image "systemd" inkludiert) von [](https://cloud-images.ubuntu.com/wsl/noble/current/ubuntu-noble-wsl-amd64-ubuntu.rootfs.tar.gz)

2. Falls noch nie verwendet, bitte zuerst wsl aktivieren (in cmd.exe oder Powershell, jeweils als Administrator)
```PowerShell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
wsl --set-default-version 2
```
**!WICHTIG!**
Es kann nötig sein, Windows neu zu starten, v.a. nach Fehlermeldung, dass wsl.exe die Parameter nicht findet !!!

danach eine Distribution installieren.
```PowerShell
wsl --install -d Ubuntu-24.04
```

Bei folgender oder ähnlicher Fehlermeldung "WslRegisterDistribution failed with error: 0x800701bc" den Befehl
```PowerShell
wsl --update
```
ausführen.
 
die weiteren Schritte können übersprungen werden, es gibt ja bereits eine aktive Distro

3. Installieren und Aktivieren dieser Distro in cmd.exe oder Powershell
   (Annahme: dass der Download der Datei .\ubuntu-noble-wsl-amd64-ubuntu.rootfs.tar.gz nach %USERPROFILE%\Downloads gemacht wurde)

```PowerShell
cd %USERPROFILE%\Downloads
wsl.exe --import Ubuntu-24.04 %USERPROFILE%\AppData\Local\Packages\Ubuntu-24.04 .\ubuntu-noble-wsl-amd64-ubuntu.rootfs.tar.gz # .\ubuntu-mantic-wsl-amd64-wsl.rootfs.tar.gz
```
Optionales Setzen dieser Distro als Default, dann muss man nicht immer explizit "wsl -d" ausführen, sondern braucht nur "bash" ausführen
```PowerShell
wsl --setdefault Ubuntu-24.04
wsl -d Ubuntu-24.04
```