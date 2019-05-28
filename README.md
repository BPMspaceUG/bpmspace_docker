# Installation
## under Windows Subsystem einrichten
Install https://docs.docker.com/docker-for-windows/
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
  SMTP relay host 172.28.1.200:1025
  as default BUT DEPENDING on IP_MAILHOG and SUBNET_NETWORK defnied in $HOME/bpmspace_docker/general.secret.conf
  will be downloaded later
- apt-get install mariadb-client
- Get Docker CE for Debian https://docs.docker.com/install/linux/docker-ce/debian/
    - sudo apt-get update
    - sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common
    - curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    - sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/debian \
        $(lsb_release -cs) \
        stable"
    - sudo apt-get update
    - sudo apt-get install docker-ce docker-ce-cli containerd.io
    - docker -H localhost:2375 images
    - export DOCKER_HOST=localhost:2375
    - docker images
    
- https://medium.com/@sebagomez/installing-the-docker-client-on-ubuntus-windows-subsystem-for-linux-612b392a44c4
- exit

BACK as NORMAL USER !!!!!!!!!
- cd $HOME
- git clone https://github.com/BPMspaceUG/bpmspace_docker.git
- cd bpmspace_docker/
- chmod +x *.sh
- cp general.EXAMPLE_secret.conf general.secret.conf


