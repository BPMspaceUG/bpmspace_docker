#!/bin/bash
docker run \
    -v DEV-LIAM2-www-data:/home/developer/LIAM2Server \
    -v DEV-LIAM2-CLIENT-www-data:/home/developer/LIAM2Client \
    -p 2222:22 -d --name tmpsftpserver atmoz/sftp  \
    developer:pass:1001
docker exec -it tmpsftpserver /bin/sh -c  "chown developer /home/developer/LIAM2* && adduser developer www-data"
	
	
	