#!/bin/bash
docker container stop $(sudo docker container ls -a -q)
docker container prune -f
docker volume prune -f
docker network prune -f
#docker image prune -f
#docker system prune -a -f --volumes
