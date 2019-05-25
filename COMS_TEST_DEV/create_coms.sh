#!/bin/bash
# $VOLUME_PREFIX = TEST|DEV
export VOLUME_PREFIX="TEST"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TMP_DIR=$HOME/tmp/$(date +"%m_%d_%Y_%s")
mkdir -p -- $TMP_DIR
cd $TMP_DIR

sudo docker volume create --name $VOLUME_PREFIX-COMS-www-data
sudo docker volume create --name $VOLUME_PREFIX-COMS-www-config
sudo docker volume create --name $VOLUME_PREFIX-COMS-CLIENT2-www-data
sudo docker volume create --name $VOLUME_PREFIX-COMS-CLIENT2-www-config
sudo docker volume create --name $VOLUME_PREFIX-LIAM2-www-data
sudo docker volume create --name $VOLUME_PREFIX-LIAM2-www-config
sudo docker volume create --name $VOLUME_PREFIX-LIAM2-CLIENT-www-data
sudo docker volume create --name $VOLUME_PREFIX-LIAM2-CLIENT-www-config
sudo docker volume create --name $VOLUME_PREFIX-mariadb-data
sudo docker volume create --name $VOLUME_PREFIX-mariadb-config
sudo docker volume create --name $VOLUME_PREFIX-mailhog-data
sudo docker volume create --name $VOLUME_PREFIX-mailhog-config

#open ports on Host for external access

sudo iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j ACCEPT 
sudo iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 8044 -j ACCEPT 
sudo iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 8180 -j ACCEPT 
sudo iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 8144 -j ACCEPT 
sudo iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 8280 -j ACCEPT 
sudo iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 8244 -j ACCEPT 
sudo iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 8380 -j ACCEPT 
sudo iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 8344 -j ACCEPT 
sudo iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 8025 -j ACCEPT 


#download DB CONFIG
sudo wget https://raw.githubusercontent.com/BPMspaceUG/LIAM2/master/sqldump/20190516_dump_liam2_structure_v2_incl_mindata.sql -P $TMP_DIR

# download git LIAM2 and LIAM2-client directly in the right volume- change owner
sudo git clone https://github.com/BPMspaceUG/LIAM2.git /var/lib/docker/volumes/TEST-LIAM2-www-data/_data
sudo git clone https://github.com/BPMspaceUG/LIAM2-Client.git /var/lib/docker/volumes/TEST-LIAM2-CLIENT-www-data/_data

sudo cp $DIR/LIAM2Server/bpmspace_liam2_v2-config.secret.inc.php /var/lib/docker/volumes/TEST-LIAM2-www-data/_data
#sudo cp $DIR/php-apache/php.ini /var/lib/docker/volumes/TEST-LIAM2-www-config/_data
sudo chown -R www-data:www-data /var/lib/docker/volumes/TEST-LIAM2-www-data/_data/

sudo cp $DIR/LIAM2Client/LIAM2_Client_api.secret.inc.php /var/lib/docker/volumes/TEST-LIAM2-CLIENT-www-data/_data/inc
sudo chown -R www-data:www-data /var/lib/docker/volumes/TEST-LIAM2-CLIENT-www-data/_data/

# Start enviroment - oder of parameters IMPORTANT
#echo $DIR
sudo docker-compose -f $DIR/docker-compose.yml up -d 

# import DB
sudo echo "sleep 20s until DB is up"
sudo sleep 20s
sudo echo "IMPORT DB"
sudo mysql -u root -pBPMSpaceTEST -h 172.28.1.10 --port 3306 < $TMP_DIR/20190516_dump_liam2_structure_v2_incl_mindata.sql
sudo rm -f $DIR/*.sql*

# restart Postfix and send testmail
sudo echo "Send Testmail"
sudo docker exec -it comstestdev_liam2-php-apache_1 /bin/sh -c  "service postfix restart"
sudo docker exec -it comstestdev_liam2-php-apache_1 /bin/sh -c  "php -r 'mail(\"mailhog@bpmspace.net\", \"test from LIAM2 Server\", time(), \"From: liam2 <liam2@bpmspace.net>\");'"
sudo docker exec -it comstestdev_liam2-client-php-apache_1 /bin/sh -c  "service postfix restart"
sudo docker exec -it comstestdev_liam2-client-php-apache_1 /bin/sh -c  "php -r 'mail(\"mailhog@bpmspace.net\", \"test from LIAM2 Client\", time(), \"From: liam2-client <liam2-client@bpmspace.net>\");'"




cd $HOME
sudo rm -rf $TMP_DIR

#if [ ! -d "$FOLDER" ] ; then
#   git clone $URL $FOLDER
#else
    #cd "$FOLDER"
    #git pull $URL
#fi

