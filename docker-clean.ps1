docker stop  $(docker ps -a -q) 
docker rm $(docker ps -a -q) 
docker network prune -f  
docker  run -d --restart=always -p 127.0.0.1:23750:2375 -v /var/run/docker.sock:/var/run/docker.sock  alpine/socat  tcp-listen:2375,fork,reuseaddr unix-connect:/var/run/docker.sock
