# Installation
## under Windows Subsystem einrichten
Install Windows Subsystem for Linux (WSL) on on Windows 10 -  https://docs.microsoft.com/en-us/windows/wsl/install-win10
Get Debian - Microsoft Store  https://www.microsoft.com/en-us/p/debian/9msvkqc78pk6?rtc=1&activetab=pivot%3Aoverviewtab
cretae own USER - Remember Passwd! or store in lastpass

## under LINUX HOST oder in a Windows Subsystem for Linux (WSL) 
AS ROOT
- sudo su root 
- apt-get update
- apt-get install git
- apt-get install postfix
  Satellite Subsystem
  Hostname - as you like
   SMTP relay host 172.28.1.200:1025 - default BUT DEPENDING on IP_MAILHOG and SUBNET_NETWORK defnied in $HOME/bpmspace_docker/general.secret.conf - will be downloaded later
- apt-get install docker
- apt-get install docker-compose
- exit
BACK as NORMAL USER !!!!!!!!!
- cd $HOME
- git clone https://github.com/BPMspaceUG/bpmspace_docker.git
- cd bpmspace_docker/
- chmod +x *.sh
- cp general.EXAMPLE_secret.conf general.secret.conf


