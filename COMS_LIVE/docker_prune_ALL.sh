#!/bin/bash
sudo docker container stop $(sudo docker container ls -a -q)
sudo docker container prune -f
sudo docker volume prune -f
sudo docker network prune -f
#sudo docker image prune -f
#sudo docker system prune -a -f --volumes