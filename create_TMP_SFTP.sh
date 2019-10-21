#!/bin/bash
docker build -t tmpsftpserver_img -f ./_tmp_sftp/Dockerfile .
docker run \
    -v bpmspace_docker:/home/developer/bpmspace_docker \
    -v DEV-LIAM2-www-data:/home/developer/LIAM2Server \
    -v DEV-LIAM2-CLIENT-www-data:/home/developer/LIAM2Client \
    -v DEV-COMS-CLIENT2-www-data:/home/developer/COMSClient2 \
    -p 2222:22 -d --name tmpsftpserver tmpsftpserver_img  \
    developer:pass:1001
docker exec -it tmpsftpserver /bin/sh -c  "chown -R developer /home/developer/* && adduser developer www-data"
	
	
	