## Anleitung, um ein frisches wsl (Windows Subsystem for Linux) vorzubereiten - geht schneller und einfacher als mit virtueller Maschine
# Damit WSL generell funktioniert, muss Windows 10, Version 2004 und höher (Build 19041 und höher) oder Windows 11 installiert sein

# wir verwenden eine neue, frische Distro, damit eine ev. bereits installierte Distribution nicht beeinflusst wird
# siehe z.B. Anleitung unter https://superuser.com/questions/1515246/how-to-add-second-wsl2-ubuntu-distro-fresh-install

# 1. Download eines Tar-Archives, z.B. für Distro 23-10 von https://cloud-images.ubuntu.com/wsl/mantic/current/ubuntu-mantic-wsl-amd64-wsl.rootfs.tar.gz

# 2. Falls noch nie verwendet, bitte zuerst wsl aktivieren (in cmd.exe oder Powershell, jeweils als Administrator)
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
wsl --set-default-version 2

# falls man Fehlermeldung "The service cannot be started, either because it is disabled or because it has no enabled devices associated with it",
# könnte es am Virenscanner liegen, der wsl blockiert. Für Kaspersky z.B. ist folgendes Kommando nötig
# sc config LxssManager start=auto

# 3. Installieren und Aktivieren dieser Distro in cmd.exe
# (Annahme: dass der Download der Datei .\ubuntu-mantic-wsl-amd64-wsl.rootfs.tar.gz nach %USERPROFILE%\Downloads gemacht wurde)

cd %USERPROFILE%\Downloads
wsl.exe --import Ubuntu-23.10 %USERPROFILE%\AppData\Local\Packages\Ubuntu-23.10 .\ubuntu-mantic-wsl-amd64-wsl.rootfs.tar.gz
# Optionales Setzen dieser Distro als Default, dann muss man nicht immer explizit "wsl -d" ausführen, sondern braucht nur "bash" ausführen
wsl --setdefault Ubuntu-23.10
wsl -d Ubuntu-23.10

# Wenn der Linux-Prompt erscheint, dann weitermachen mit Scripts aus diesem Verzeichnis