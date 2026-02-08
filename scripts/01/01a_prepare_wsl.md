# DBSec01 - prepare WSL

## Instructions to prepare a fresh WSL (Windows Subsystem for Linux)

This is faster and easier than using a virtual machine (VMWare, VirtualBox etc.)

We use a new, fresh distro so that any already installed distribution is not affected.
See e.g. the instructions at [](https://superuser.com/questions/1515246/how-to-add-second-wsl2-ubuntu-distro-fresh-install)

1. Download a tar archive, e.g. for Distro 24.04 (because this image includes `systemd`) from [](https://cloud-images.ubuntu.com/wsl/noble/current/ubuntu-noble-wsl-amd64-ubuntu.rootfs.tar.gz)

2. If never used before, first enable WSL (in `cmd.exe` or PowerShell, each as Administrator)
```PowerShell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
wsl --set-default-version 2
```
**IMPORTANT**
It may be necessary to restart Windows, especially after an error message that `wsl.exe` cannot find the parameters!!!

Then install a distribution.
```PowerShell
wsl --install -d Ubuntu-24.04
```

If you encounter the following or a similar error
> WslRegisterDistribution failed with error: 0x800701bc

then run

```PowerShell
wsl --update
```

The following steps can be skipped if there is already an active distro.

3. Install and register this distro in `cmd.exe` or PowerShell
   (Assumption: the downloaded file `.\ubuntu-noble-wsl-amd64-ubuntu.rootfs.tar.gz` was saved to `\%USERPROFILE%\Downloads`)

```PowerShell
cd `\%USERPROFILE%\Downloads
wsl.exe --import Ubuntu-24.04 `\%USERPROFILE%\AppData\Local\Packages\Ubuntu-24.04 .\ubuntu-noble-wsl-amd64-ubuntu.rootfs.tar.gz # .\ubuntu-mantic-wsl-amd64-wsl.rootfs.tar.gz
```
Optional: set this distro as default, then you don't have to always run `wsl -d` explicitly — you can just run `bash`
```PowerShell
wsl --setdefault Ubuntu-24.04
wsl -d Ubuntu-24.04
```
