#!/bin/bash
# get (secret) parameters
SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TMP_DIR=$HOME/tmp/$(date +"%m_%d_%Y_%s")
mkdir -p -- $TMP_DIR
cd $TMP_DIR
source $SCRIPT/general.secret.conf

############TODO - TEST IF PREFIX="STAGE"|"TEST"|"DEV" or exit https://rsalveti.wordpress.com/2007/04/03/bash-parsing-arguments-with-getopts/

LIAM2_SERVER=$(echo "$PREFIX" | tr '[:upper:]' '[:lower:]')"_liam2-php-apache_1"
LIAM2_CLIENT=$(echo "$PREFIX" | tr '[:upper:]' '[:lower:]')"_liam2-client-php-apache_1"
MARIADB=$(echo "$PREFIX" | tr '[:upper:]' '[:lower:]')"_mariadb_1"
MAILHOG=$(echo "$PREFIX" | tr '[:upper:]' '[:lower:]')"_mailhog"


echo "LIAM2_SERVER: "$LIAM2_SERVER
echo "LIAM2_CLIENT: "$LIAM2_CLIENT

 docker volume create --name $PREFIX-LIAM2-www-data
 docker volume create --name $PREFIX-LIAM2-www-config
 docker volume create --name $PREFIX-LIAM2-CLIENT-www-data
 docker volume create --name $PREFIX-LIAM2-CLIENT-www-config
 docker volume create --name $PREFIX-mariadb-data
 docker volume create --name $PREFIX-mariadb-config
 docker volume create --name $PREFIX-mailhog-data
 docker volume create --name $PREFIX-mailhog-config

#open ports on Host for external access

 iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport $EXT_PORT_MARIADB_SQL -j ACCEPT 
 iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport $EXT_PORT_MAILHOG_SMPT -j REJECT 
 iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport $EXT_PORT_MAILHOG_HTTP -j ACCEPT 
 iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport $EXT_PORT_LIAM2_HTTP -j ACCEPT 
 iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport $EXT_PORT_LIAM2_HTTPS -j ACCEPT 
 iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport $EXT_PORT_LIAM2_CLIENT_HTTP -j ACCEPT 
 iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport $EXT_PORT_LIAM2_CLIENT_HTTPS -j ACCEPT 

#download DB LIAM2 Structure and minimum Data
 wget $LIAM2_SQLDUMP_URL$LIAM2_SQLDUMP_FILE -P $TMP_DIR

# download git LIAM2 and LIAM2-client directly in the right volume + change owner
sudo git clone $LIAM2_GITHUB_REPO_URL /var/lib/docker/volumes/$PREFIX-LIAM2-www-data/_data
sudo git clone $LIAM2_CLIENT_GITHUB_REPO_URL /var/lib/docker/volumes/$PREFIX-LIAM2-CLIENT-www-data/_data

# copy LIAM config to temp + replace PASS + copy to LIAM Server volume + change owner
 cp $SCRIPT/LIAM2_STAGE_TEST_DEV/LIAM2Server/bpmspace_liam2_v2-config.secret.inc.php $TMP_DIR
 sed -i "s/AUTOMATICALLYSET/$DB_ROOT_PASSWD/g" $TMP_DIR/bpmspace_liam2_v2-config.secret.inc.php
 sed -i "s/IP_MARIADB/$IP_MARIADB/g" $TMP_DIR/bpmspace_liam2_v2-config.secret.inc.php
 sed -i "s/EXT_PORT_LIAM2_HTTP/$EXT_PORT_LIAM2_HTTP/g" $TMP_DIR/bpmspace_liam2_v2-config.secret.inc.php
 sed -i "s/HOSTNAME/$HOSTNAME/g" $TMP_DIR/bpmspace_liam2_v2-config.secret.inc.php
sudo cp $TMP_DIR/bpmspace_liam2_v2-config.secret.inc.php /var/lib/docker/volumes/$PREFIX-LIAM2-www-data/_data 
sudo chown -R www-data:www-data /var/lib/docker/volumes/$PREFIX-LIAM2-www-data/_data/

# copy LIAM CLIENT config to temp + copy to LIAM Client volume + change owner
 cp $SCRIPT/LIAM2_STAGE_TEST_DEV/LIAM2Client/LIAM2_Client_api.secret.inc.php $TMP_DIR
sudo cp $TMP_DIR/LIAM2_Client_api.secret.inc.php /var/lib/docker/volumes/$PREFIX-LIAM2-CLIENT-www-data/_data/inc
sudo chown -R www-data:www-data /var/lib/docker/volumes/$PREFIX-LIAM2-CLIENT-www-data/_data/


#copy composer to temp - replace parameter from config file - Start enviroment - ORDER of switches IMPORTANT
#echo $SCRIPT
cp $SCRIPT/LIAM2_STAGE_TEST_DEV/docker-compose.yml $TMP_DIR/docker-compose.yml
sed -i "s/AUTOMATICALLYSET/$DB_ROOT_PASSWD/g" $TMP_DIR/docker-compose.yml
sed -i "s/PREFIX/$PREFIX/g" $TMP_DIR/docker-compose.yml
sed -i "s/DOCKERNETWORK/$DOCKERNETWORK/g" $TMP_DIR/docker-compose.yml
sed -i "s/DOCKERNETMASK/$DOCKERNETMASK/g" $TMP_DIR/docker-compose.yml
sed -i "s/SCRI/$SCRIPT/g" $TMP_DIR/docker-compose.yml
echo "!"


sed -i "s/EXT_PORT_MARIADB_SQL/$EXT_PORT_MARIADB_SQL/g" $TMP_DIR/docker-compose.yml
sed -i "s/IP_MARIADB/$IP_MARIADB/g" $TMP_DIR/docker-compose.yml

sed -i "s/EXT_PORT_MAILHOG_SMPT/$EXT_PORT_MAILHOG_SMPT/g" $TMP_DIR/docker-compose.yml
sed -i "s/EXT_PORT_MAILHOG_HTTP/$EXT_PORT_MAILHOG_HTTP/g" $TMP_DIR/docker-compose.yml
sed -i "s/IP_MAILHOG/$IP_MAILHOG/g" $TMP_DIR/docker-compose.yml


sed -i "s/EXT_PORT_LIAM2_CLIENT_HTTPS/$EXT_PORT_LIAM2_CLIENT_HTTPS/g" $TMP_DIR/docker-compose.yml
sed -i "s/EXT_PORT_LIAM2_CLIENT_HTTP/$EXT_PORT_LIAM2_CLIENT_HTTP/g" $TMP_DIR/docker-compose.yml
sed -i "s/IP_LIAM2_CLIENT/$IP_LIAM2_CLIENT/g" $TMP_DIR/docker-compose.yml

sed -i "s/EXT_PORT_LIAM2_HTTPS/$EXT_PORT_LIAM2_HTTPS/g" $TMP_DIR/docker-compose.yml
sed -i "s/EXT_PORT_LIAM2_HTTP/$EXT_PORT_LIAM2_HTTP/g" $TMP_DIR/docker-compose.yml
sed -i "s/IP_LIAM2/$IP_LIAM2/g" $TMP_DIR/docker-compose.yml

# prepare Acceptance Mail 
wget $LIAM2_ACCEPTANCETEST_URL/$LIAM2_ACCEPTANCETEST_FILE -P $TMP_DIR
sed -i "s/HOSTNAME/$HOSTNAME/g" $TMP_DIR/$LIAM2_ACCEPTANCETEST_FILE
sed -i "s/EXT_PORT_MAILHOG_HTTP/$EXT_PORT_MAILHOG_HTTP/g" $TMP_DIR/$LIAM2_ACCEPTANCETEST_FILE
sed -i "s/EXT_PORT_LIAM2_CLIENT_HTTPS/$EXT_PORT_LIAM2_CLIENT_HTTPS/g" $TMP_DIR/$LIAM2_ACCEPTANCETEST_FILE
sed -i "s/EXT_PORT_LIAM2_CLIENT_HTTP/$EXT_PORT_LIAM2_CLIENT_HTTP/g" $TMP_DIR/$LIAM2_ACCEPTANCETEST_FILE
sed -i "s/EXT_PORT_LIAM2_HTTPS/$EXT_PORT_LIAM2_HTTPS/g" $TMP_DIR/$LIAM2_ACCEPTANCETEST_FILE
sed -i "s/EXT_PORT_LIAM2_HTTP/$EXT_PORT_LIAM2_HTTP/g" $TMP_DIR/$LIAM2_ACCEPTANCETEST_FILE
sed -i "s/EXT_PORT_MARIADB_SQL/$EXT_PORT_MARIADB_SQL/g" $TMP_DIR/$LIAM2_ACCEPTANCETEST_FILE
sed -i "s/DB_ROOT_PASSWD/$DB_ROOT_PASSWD/g" $TMP_DIR/$LIAM2_ACCEPTANCETEST_FILE
#LIAM2_ACCEPTANCETEST_VAR= `cat `$TMP_DIR/$LIAM2_ACCEPTANCETEST_FILE
IFS= read -r -d '' LIAM2_ACCEPTANCETEST_VAR <$TMP_DIR/$LIAM2_ACCEPTANCETEST_FILE
LIAM2_ACCEPTANCETEST_VAR=${LIAM2_ACCEPTANCETEST_VAR//'"'/'\"'/}
LIAM2_ACCEPTANCETEST_VAR=${LIAM2_ACCEPTANCETEST_VAR//$'\n'/'\n'}


# start Enviroment
 docker-compose -p $PREFIX -f $TMP_DIR/docker-compose.yml up -d

#import DB

 echo "sleep 20s until DB is up"
for i in {20..1}
		do echo -e "\r"&& echo -n "$i." && sleep 1
		done
 echo "IMPORT DB"
 mysql -u root -p$DB_ROOT_PASSWD -h $IP_MARIADB --port 3306 < $TMP_DIR/$LIAM2_SQLDUMP_FILE
 rm -f $SCRIPT/*.sql*


# config Mail relay & restart Postfix and send testmail
cp $SCRIPT/_bpmspace_base/main.cf $TMP_DIR/LIAM2-Server_main.cf
cp $SCRIPT/_bpmspace_base/main.cf $TMP_DIR/LIAM2-Client_main.cf

#sed -i "s/IP_MAILHOG/$IP_MAILHOG/g" $TMP_DIR/LIAM2-Server_main.cf
#sed -i "s/IP_MAILHOG/$IP_MAILHOG/g" $TMP_DIR/LIAM2-Client_main.cf
#sed -i "s/SERVERNAME/$LIAM2-SERVER/g" $TMP_DIR/LIAM2-Server_main.cf
#sed -i "s/SERVERNAME/$LIAM2-CLIENT/g" $TMP_DIR/LIAM2-Client_main.cf
#sed -i "s/EXT_PORT_MAILHOG_SMPT/$EXT_PORT_MAILHOG_SMPT/g" $TMP_DIR/LIAM2-Server_main.cf
#sed -i "s/EXT_PORT_MAILHOG_SMPT/$EXT_PORT_MAILHOG_SMPT/g" $TMP_DIR/LIAM2-Client_main.cf
 docker cp $TMP_DIR/LIAM2-Server_main.cf $LIAM2_SERVER:/etc/postfix/main.cf
 docker cp $TMP_DIR/LIAM2-Client_main.cf $LIAM2_CLIENT:/etc/postfix/main.cf

#prepare fetch all command
echo "prepare fetch all command"
cp $SCRIPT/_bpmspace_base/fetch_all.php $TMP_DIR/fetch_all.php
cp $SCRIPT/_bpmspace_base/fetch_all.sh $TMP_DIR/fetch_all.sh

docker exec -it $LIAM2_SERVER /bin/sh -c  "mkdir -p -- /var/www/script/"
docker cp $TMP_DIR/fetch_all.php $LIAM2_SERVER:/var/www/html/fetch_all.php
docker cp $TMP_DIR/fetch_all.sh $LIAM2_SERVER:/var/www/script/fetch_all.sh


docker exec -it $LIAM2_CLIENT /bin/sh -c  "mkdir -p -- /var/www/script/"
docker cp $TMP_DIR/fetch_all.php $LIAM2_CLIENT:/var/www/html/fetch_all.php
docker cp $TMP_DIR/fetch_all.sh $LIAM2_CLIENT:/var/www/script/fetch_all.sh

#prepare DB import command
echo "prepare DB import command"
cp $SCRIPT/LIAM2_STAGE_TEST_DEV/LIAM2Server/import_db.php $TMP_DIR/import_db.php
cp $SCRIPT/LIAM2_STAGE_TEST_DEV/LIAM2Server/import_db.sh $TMP_DIR/import_db.sh
cp $SCRIPT/LIAM2_STAGE_TEST_DEV/LIAM2Server/import_dbdiff.php $TMP_DIR/import_dbdiff.php
cp $SCRIPT/LIAM2_STAGE_TEST_DEV/LIAM2Server/import_dbdiff.sh $TMP_DIR/import_dbdiff.sh

sed -i "s/DB_ROOT_PASSWD/$DB_ROOT_PASSWD/g" $TMP_DIR/import_db.sh
sed -i "s/DB_ROOT_PASSWD/$DB_ROOT_PASSWD/g" $TMP_DIR/import_dbdiff.sh
sed -i "s/IP_MARIADB/$IP_MARIADB/g" $TMP_DIR/import_db.sh
sed -i "s/IP_MARIADB/$IP_MARIADB/g" $TMP_DIR/import_dbdiff.sh
sed -i "s/LIAM2_SQLDUMP_FILE_DIFF/$LIAM2_SQLDUMP_FILE_DIFF/g" $TMP_DIR/import_dbdiff.sh
sed -i "s/LIAM2_SQLDUMP_FILE/$LIAM2_SQLDUMP_FILE/g" $TMP_DIR/import_db.sh

docker cp $TMP_DIR/import_db.php $LIAM2_SERVER:/var/www/html/import_db.php
docker cp $TMP_DIR/import_dbdiff.php $LIAM2_SERVER:/var/www/html/import_dbdiff.php
docker cp $TMP_DIR/import_db.sh $LIAM2_SERVER:/var/www/script/import_db.sh
docker cp $TMP_DIR/import_dbdiff.sh $LIAM2_SERVER:/var/www/script/import_dbdiff.sh

# set owner and execute 
echo "set owner and execute"

docker exec -it $LIAM2_SERVER /bin/sh -c  "chown -R www-data:www-data /var/www/"
docker exec -it $LIAM2_SERVER /bin/sh -c  "chmod +x /var/www/script/*.sh"
docker exec -it $LIAM2_CLIENT /bin/sh -c  "chown -R www-data:www-data /var/www/"
docker exec -it $LIAM2_CLIENT /bin/sh -c  "chmod +x /var/www/script/*.sh"

# Restart Mail server and send testmail
echo "Send Testmail"
 docker exec -it $LIAM2_SERVER /bin/sh -c  "service postfix restart"
 docker exec -it $LIAM2_SERVER /bin/sh -c  "php -r 'mail(\"mailhog@bpmspace.net\", \"TEST from LIAM2 $PREFIX-Server\", date(DATE_RFC822), \"From: liam2 <liam2@bpmspace.net>\");'"
 docker exec -it $LIAM2_CLIENT /bin/sh -c  "service postfix restart"
 docker exec -it $LIAM2_CLIENT /bin/sh -c  "php -r 'mail(\"mailhog@bpmspace.net\", \"TEST from LIAM2 $PREFIX-Client\", date(DATE_RFC822), \"From: liam2-client <liam2-client@bpmspace.net>\");'"

cd $HOME
mail -s "ACCEPTANCE TEST LIAM SERVER" testuser@mailhog < $TMP_DIR/$LIAM2_ACCEPTANCETEST_FILE

printf "DONE - Please note the mail \"Acceptance Test\" on the Mailhog at http://$HOSTNAME:$EXT_PORT_MAILHOG_HTTP - thank you \n\r
		docker exec -it $LIAM2_SERVER bash \n\r
		docker exec -it $LIAM2_CLIENT bash \n\r
		docker exec -it $MARIADB bash \n\r
		docker exec -it $MAILHOG bash \n\r
	"
printf "\n\r$LIAM2_ACCEPTANCETEST_VAR \n\r"


#rm -rf $TMP_DIR

#if [ ! -d "$FOLDER" ] ; then
#   git clone $URL $FOLDER
#else
    #cd "$FOLDER"
    #git pull $URL
#fi

