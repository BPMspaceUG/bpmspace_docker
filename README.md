# Installation
## under Windows Subsystem einrichten
Install Windows Subsystem for Linux (WSL) on on Windows 10 -  https://docs.microsoft.com/en-us/windows/wsl/install-win10
Get Debian - Microsoft Store  https://www.microsoft.com/en-us/p/debian/9msvkqc78pk6?rtc=1&activetab=pivot%3Aoverviewtab
cretae own USER - Remember Passwd! or store in lastpas

## under LINUX HOST oder in a Windows Subsystem for Linux (WSL) 
- sudo su root 
- apt-get update
- apt-get install git
- apt-get install postfix
-- Satellite Subsystem
-- Hostname - as you like
-- SMTP relay host 


  

1. create virtuall machine with http://cdimage.debian.org/debian-cd/current/arm64/iso-cd/debian-9.9.0-arm64-netinst.iso OR NEWER
  Name: BPMspace_docker_enviroment
  Generation: Generation 2
  Arbeitsspeicher: 2048 MB
  Netzwerk: DockerNAT
  Festplatte: C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks\BPMspace_docker_enviroment.vhdx (VHDX, dynamisch erweiterbar)
  Betriebssystem: Installation von "C:\Users\USERNAME\Downloads\debian-9.9.0-arm64-netinst.iso"
  
