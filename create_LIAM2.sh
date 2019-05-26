#!/bin/bash
# get (secret) parameters
source $DIR/general.secret.conf

sudo docker volume create --name $PREFIX-LIAM2-www-data
sudo docker volume create --name $PREFIX-LIAM2-www-config
sudo docker volume create --name $PREFIX-LIAM2-CLIENT-www-data
sudo docker volume create --name $PREFIX-LIAM2-CLIENT-www-config
sudo docker volume create --name $PREFIX-mariadb-data
sudo docker volume create --name $PREFIX-mariadb-config
sudo docker volume create --name $PREFIX-mailhog-data
sudo docker volume create --name $PREFIX-mailhog-config

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


#download DB LIAM2 Structure and minimum Data
sudo wget https://raw.githubusercontent.com/BPMspaceUG/LIAM2/master/sqldump/20190516_dump_liam2_structure_v2_incl_mindata.sql -P $TMP_DIR

# download git LIAM2 and LIAM2-client directly in the right volume + change owner
sudo git clone https://github.com/BPMspaceUG/LIAM2.git /var/lib/docker/volumes/$PREFIX-LIAM2-www-data/_data
sudo git clone https://github.com/BPMspaceUG/LIAM2-Client.git /var/lib/docker/volumes/$PREFIX-LIAM2-CLIENT-www-data/_data

# copy LIAM config to temp + replace PASS + copy to LIAM Server volume + change owner
sudo cp $DIR/LIAM2_STAGE_TEST_DEV/LIAM2Server/bpmspace_liam2_v2-config.secret.inc.php $TMP_DIR
sudo sed -i "s/AUTOMATICALLYSET/$DB_ROOT_PASSWD/g" $TMP_DIR/bpmspace_liam2_v2-config.secret.inc.php
sudo cp $TMP_DIR/bpmspace_liam2_v2-config.secret.inc.php /var/lib/docker/volumes/$PREFIX-LIAM2-www-data/_data 
sudo chown -R www-data:www-data /var/lib/docker/volumes/$PREFIX-LIAM2-www-data/_data/

# copy LIAM CLIENT config to temp + copy to LIAM Client volume + change owner
sudo cp $DIR/LIAM2_STAGE_TEST_DEV/LIAM2Client/LIAM2_Client_api.secret.inc.php $TMP_DIR
sudo cp $TMP_DIR/LIAM2_Client_api.secret.inc.php /var/lib/docker/volumes/$PREFIX-LIAM2-CLIENT-www-data/_data/inc
sudo chown -R www-data:www-data /var/lib/docker/volumes/$PREFIX-LIAM2-CLIENT-www-data/_data/

#copy composer to temp - replace parameter - Start enviroment - ORDER of switches IMPORTANT
#echo $DIR
cp $DIR/LIAM2_STAGE_TEST_DEV/docker-compose.yml $TMP_DIR/docker-compose.yml
sed -i "s/AUTOMATICALLYSET/$DB_ROOT_PASSWD/g" $TMP_DIR/docker-compose.yml
sed -i "s/PREFIX/$PREFIX/g" $TMP_DIR/docker-compose.yml
sudo docker-compose -f $TMP_DIR/docker-compose.yml up -d

# import DB
sudo echo "sleep 20s until DB is up"
sudo sleep 20s
sudo echo "IMPORT DB"
sudo mysql -u root -p$DB_ROOT_PASSWD -h 172.28.1.10 --port 3306 < $TMP_DIR/20190516_dump_liam2_structure_v2_incl_mindata.sql
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

