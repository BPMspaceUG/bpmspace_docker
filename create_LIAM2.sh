#!/bin/bash
SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TMP_DIR=$HOME/tmp/$(date +"%m_%d_%Y_%s")

#create TEMP Folder and SUB
mkdir -p -- $TMP_DIR
mkdir -p -- $TMP_DIR/_bpmspace_base
mkdir -p -- $TMP_DIR/LIAM2-SERVER_var-www-html/
mkdir -p -- $TMP_DIR/LIAM2-CLIENT-html/
cd $TMP_DIR
# get (secret) parameters
source $SCRIPT/general.secret.conf

############TODO - TEST IF PREFIX="STAGE"|"TEST"|"DEV"|TESTDEV or exit https://rsalveti.wordpress.com/2007/04/03/bash-parsing-arguments-with-getopts/

LIAM2_SERVER=$(echo "$PREFIX" | tr '[:upper:]' '[:lower:]')"_liam2-php-apache_1"
LIAM2_CLIENT=$(echo "$PREFIX" | tr '[:upper:]' '[:lower:]')"_liam2-client-php-apache_1"
MARIADB=$(echo "$PREFIX" | tr '[:upper:]' '[:lower:]')"_mariadb_1"
MAILHOG=$(echo "$PREFIX" | tr '[:upper:]' '[:lower:]')"_mailhog"

# Delete volumes 
#sudo rm -rf /var/lib/docker/volumes/$PREFIX-LIAM2-www-data/_data/
#sudo rm -rf /var/lib/docker/volumes/$PREFIX-LIAM2-CLIENT-www-data/_data/

# create docker
docker volume create --name $PREFIX-LIAM2-www-data
docker volume create --name $PREFIX-LIAM2-www-config
docker volume create --name $PREFIX-LIAM2-CLIENT-www-data
docker volume create --name $PREFIX-LIAM2-CLIENT-www-config
docker volume create --name $PREFIX-mariadb-data
docker volume create --name $PREFIX-mariadb-config
docker volume create --name $PREFIX-mailhog-data
docker volume create --name $PREFIX-mailhog-config

#download DB LIAM2 Structure and minimum Data
 wget $LIAM2_SQLDUMP_URL$LIAM2_SQLDUMP_FILE -P $TMP_DIR

# download git LIAM2 and LIAM2-client in a temp HTML dir + change owner
git clone $LIAM2_GITHUB_REPO_URL $TMP_DIR/LIAM2-SERVER-html/
git clone $LIAM2_CLIENT_GITHUB_REPO_URL $TMP_DIR/LIAM2-CLIENT-html/

# copy LIAM config to HTML temp  Folder + replace Parameters
cp $SCRIPT/LIAM2_STAGE_TEST_DEV/LIAM2Server/bpmspace_liam2_v2-config_EXAMPLEsecret.inc.php $TMP_DIR/LIAM2-SERVER-html/bpmspace_liam2_v2-config.secret.inc.php
sed -i "s/MARIADB_ROOT_PASSWD/$MARIADB_ROOT_PASSWD/g" $TMP_DIR/LIAM2-SERVER-html/bpmspace_liam2_v2-config.secret.inc.php
sed -i "s/MARIADB_IP/$MARIADB_IP/g" $TMP_DIR/LIAM2-SERVER-html/bpmspace_liam2_v2-config.secret.inc.php
sed -i "s/LIAM2_DB_NAME/$LIAM2_DB_NAME/g" $TMP_DIR/LIAM2-SERVER-html/bpmspace_liam2_v2-config.secret.inc.php
sed -i "s/EXT_PORT_LIAM2_HTTP/$EXT_PORT_LIAM2_HTTP/g" $TMP_DIR/LIAM2-SERVER-html/bpmspace_liam2_v2-config.secret.inc.php
sed -i "s/HOSTNAME/$HOSTNAME/g" $TMP_DIR/LIAM2-SERVER-html/bpmspace_liam2_v2-config.secret.inc.php

# copy LIAM CLIENT config to temp HTML dir
cp $SCRIPT/LIAM2_STAGE_TEST_DEV/LIAM2Client/LIAM2_Client_api_EXAMPLEsecret.inc.php $TMP_DIR/LIAM2_Client_api.secret.inc.php
sudo cp $TMP_DIR/LIAM2_Client_api.secret.inc.php $TMP_DIR/LIAM2-CLIENT-html/inc
sudo chown -R www-data:www-data $TMP_DIR/LIAM2-CLIENT-html/

#copy docker-compose to temp - replace parameter from config file - Start enviroment - ORDER of switches IMPORTANT
cp $SCRIPT/LIAM2_STAGE_TEST_DEV/docker-compose.yml $TMP_DIR/docker-compose.yml
cp $SCRIPT/_bpmspace_base/Dockerfile $TMP_DIR/_bpmspace_base/Dockerfile
sed -i "s/MARIADB_ROOT_PASSWD/$MARIADB_ROOT_PASSWD/g" $TMP_DIR/docker-compose.yml
sed -i "s/PREFIX/$PREFIX/g" $TMP_DIR/docker-compose.yml
sed -i "s/DOCKERNETWORK/$DOCKERNETWORK/g" $TMP_DIR/docker-compose.yml
sed -i "s/DOCKERNETMASK/$DOCKERNETMASK/g" $TMP_DIR/docker-compose.yml
sed -i "s/LIAM2_DB_NAME/$LIAM2_DB_NAME/g" $TMP_DIR/docker-compose.yml
sed -i "s/MARIADB_EXT_PORT_SQL/$MARIADB_EXT_PORT_SQL/g" $TMP_DIR/docker-compose.yml
sed -i "s/MARIADB_IP/$MARIADB_IP/g" $TMP_DIR/docker-compose.yml
sed -i "s/EXT_PORT_MAILHOG_SMPT/$EXT_PORT_MAILHOG_SMPT/g" $TMP_DIR/docker-compose.yml
sed -i "s/EXT_PORT_MAILHOG_HTTP/$EXT_PORT_MAILHOG_HTTP/g" $TMP_DIR/docker-compose.yml
sed -i "s/IP_MAILHOG/$IP_MAILHOG/g" $TMP_DIR/docker-compose.yml
sed -i "s/EXT_PORT_LIAM2_CLIENT_HTTPS/$EXT_PORT_LIAM2_CLIENT_HTTPS/g" $TMP_DIR/docker-compose.yml
sed -i "s/EXT_PORT_LIAM2_CLIENT_HTTP/$EXT_PORT_LIAM2_CLIENT_HTTP/g" $TMP_DIR/docker-compose.yml
sed -i "s/IP_LIAM2_CLIENT/$IP_LIAM2_CLIENT/g" $TMP_DIR/docker-compose.yml
sed -i "s/EXT_PORT_LIAM2_HTTPS/$EXT_PORT_LIAM2_HTTPS/g" $TMP_DIR/docker-compose.yml
sed -i "s/EXT_PORT_LIAM2_HTTP/$EXT_PORT_LIAM2_HTTP/g" $TMP_DIR/docker-compose.yml
sed -i "s/IP_LIAM2/$IP_LIAM2/g" $TMP_DIR/docker-compose.yml

# prepare LIAM SERVER Acceptance Mail 
wget $LIAM2_SERVER_ACCEPTANCETEST_URL/$LIAM2_SERVER_ACCEPTANCETEST_FILE -P $TMP_DIR
sed -i "s/HOSTNAME/$HOSTNAME/g" $TMP_DIR/$LIAM2_SERVER_ACCEPTANCETEST_FILE
sed -i "s/EXT_PORT_MAILHOG_HTTP/$EXT_PORT_MAILHOG_HTTP/g" $TMP_DIR/$LIAM2_SERVER_ACCEPTANCETEST_FILE
sed -i "s/EXT_PORT_LIAM2_CLIENT_HTTPS/$EXT_PORT_LIAM2_CLIENT_HTTPS/g" $TMP_DIR/$LIAM2_SERVER_ACCEPTANCETEST_FILE
sed -i "s/EXT_PORT_LIAM2_CLIENT_HTTP/$EXT_PORT_LIAM2_CLIENT_HTTP/g" $TMP_DIR/$LIAM2_SERVER_ACCEPTANCETEST_FILE
sed -i "s/EXT_PORT_LIAM2_HTTPS/$EXT_PORT_LIAM2_HTTPS/g" $TMP_DIR/$LIAM2_SERVER_ACCEPTANCETEST_FILE
sed -i "s/EXT_PORT_LIAM2_HTTP/$EXT_PORT_LIAM2_HTTP/g" $TMP_DIR/$LIAM2_SERVER_ACCEPTANCETEST_FILE
sed -i "s/MARIADB_EXT_PORT_SQL/$MARIADB_EXT_PORT_SQL/g" $TMP_DIR/$LIAM2_SERVER_ACCEPTANCETEST_FILE
sed -i "s/MARIADB_ROOT_PASSWD/$MARIADB_ROOT_PASSWD/g" $TMP_DIR/$LIAM2_SERVER_ACCEPTANCETEST_FILE
IFS= read -r -d '' LIAM2_ACCEPTANCETEST_VAR < $TMP_DIR/$LIAM2_SERVER_ACCEPTANCETEST_FILE
LIAM2_ACCEPTANCETEST_VAR=${LIAM2_ACCEPTANCETEST_VAR//'"'/'\"'/}
LIAM2_ACCEPTANCETEST_VAR=${LIAM2_ACCEPTANCETEST_VAR//$'\n'/'\n'}

# prepare LIAM SERVER Acceptance Mail 
wget $LIAM2_CLIENT_ACCEPTANCETEST_URL/$LIAM2_CLIENT_ACCEPTANCETEST_FILE -P $TMP_DIR
sed -i "s/HOSTNAME/$HOSTNAME/g" $TMP_DIR/$LIAM2_CLIENT_ACCEPTANCETEST_FILE
sed -i "s/EXT_PORT_MAILHOG_HTTP/$EXT_PORT_MAILHOG_HTTP/g" $TMP_DIR/$LIAM2_CLIENT_ACCEPTANCETEST_FILE
sed -i "s/EXT_PORT_LIAM2_CLIENT_HTTPS/$EXT_PORT_LIAM2_CLIENT_HTTPS/g" $TMP_DIR/$LIAM2_CLIENT_ACCEPTANCETEST_FILE
sed -i "s/EXT_PORT_LIAM2_CLIENT_HTTP/$EXT_PORT_LIAM2_CLIENT_HTTP/g" $TMP_DIR/$LIAM2_CLIENT_ACCEPTANCETEST_FILE
sed -i "s/EXT_PORT_LIAM2_HTTPS/$EXT_PORT_LIAM2_HTTPS/g" $TMP_DIR/$LIAM2_CLIENT_ACCEPTANCETEST_FILE
sed -i "s/EXT_PORT_LIAM2_HTTP/$EXT_PORT_LIAM2_HTTP/g" $TMP_DIR/$LIAM2_CLIENT_ACCEPTANCETEST_FILE
sed -i "s/MARIADB_EXT_PORT_SQL/$MARIADB_EXT_PORT_SQL/g" $TMP_DIR/$LIAM2_CLIENT_ACCEPTANCETEST_FILE
sed -i "s/MARIADB_ROOT_PASSWD/$MARIADB_ROOT_PASSWD/g" $TMP_DIR/$LIAM2_CLIENT_ACCEPTANCETEST_FILE
IFS= read -r -d '' LIAM2_ACCEPTANCETEST_VAR <$TMP_DIR/$LIAM2_CLIENT_ACCEPTANCETEST_FILE
LIAM2_ACCEPTANCETEST_VAR=${LIAM2_ACCEPTANCETEST_VAR//'"'/'\"'/}
LIAM2_ACCEPTANCETEST_VAR=${LIAM2_ACCEPTANCETEST_VAR//$'\n'/'\n'}







# start Enviroment
 docker-compose -p $PREFIX -f $TMP_DIR/docker-compose.yml up -d

#import DB
: '
 echo "sleep 20s until DB is up"
for i in {20..1}
		do echo -e "\r"&& echo -n "$i." && sleep 1
		done

 mysql -u root -p$MARIADB_ROOT_PASSWD -h $MARIADB_IP --port 3306 < $TMP_DIR/$LIAM2_SQLDUMP_FILE
#'
maxcounter=45
 
counter=1
while ! mysql --protocol TCP -u root -p$MARIADB_ROOT_PASSWD -h $MARIADB_IP --port 3306 -e "show databases;" > /dev/null 2>&1; do
    sleep 1
	echo "$counter seconds waiting to have DB up"
    counter=`expr $counter + 1`
    if [ $counter -gt $maxcounter ]; then
        >&2 echo "We have been waiting for MySQL too long already; failing."
        exit 1
    fi;
done
echo "IMPORT DB"
mysql -u root -p$MARIADB_ROOT_PASSWD -h $MARIADB_IP --port 3306 < $TMP_DIR/$LIAM2_SQLDUMP_FILE

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

# copy temp html dir to docker
docker cp $TMP_DIR/LIAM2-SERVER-html/. $LIAM2_SERVER:/var/www/html
docker cp $TMP_DIR/LIAM2-CLIENT-html/. $LIAM2_CLIENT:/var/www/html


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

sed -i "s/MARIADB_ROOT_PASSWD/$MARIADB_ROOT_PASSWD/g" $TMP_DIR/import_db.sh
sed -i "s/MARIADB_ROOT_PASSWD/$MARIADB_ROOT_PASSWD/g" $TMP_DIR/import_dbdiff.sh
sed -i "s/MARIADB_IP/$MARIADB_IP/g" $TMP_DIR/import_db.sh
sed -i "s/MARIADB_IP/$MARIADB_IP/g" $TMP_DIR/import_dbdiff.sh
sed -i "s/LIAM2_SQLDUMP_FILE_DIFF/$LIAM2_SQLDUMP_FILE_DIFF/g" $TMP_DIR/import_dbdiff.sh
sed -i "s/LIAM2_SQLDUMP_FILE/$LIAM2_SQLDUMP_FILE/g" $TMP_DIR/import_db.sh

docker cp $TMP_DIR/import_db.php $LIAM2_SERVER:/var/www/html/import_db.php
docker cp $TMP_DIR/import_dbdiff.php $LIAM2_SERVER:/var/www/html/import_dbdiff.php
docker cp $TMP_DIR/import_db.sh $LIAM2_SERVER:/var/www/script/import_db.sh
docker cp $TMP_DIR/import_dbdiff.sh $LIAM2_SERVER:/var/www/script/import_dbdiff.sh

# git clone repos 
docker exec -it $LIAM2_SERVER /bin/sh -c  "cd /var/www/html/ && git fetch --all && git reset --hard origin/master"
docker exec -it $LIAM2_SERVER /bin/sh -c  "cd /var/www/html/ && git fetch --all && git reset --hard origin/master"

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
#mail -s "ACCEPTANCE TEST LIAM SERVER" testuser@mailhog < $TMP_DIR/$LIAM2_SERVER_ACCEPTANCETEST_FILE
sudo markdown $TMP_DIR/$LIAM2_SERVER_ACCEPTANCETEST_FILE > $DOCKERHOSTWWWPATH/LIAM2-Server.html
sudo markdown $TMP_DIR/$LIAM2_CLIENT_ACCEPTANCETEST_FILE > $DOCKERHOSTWWWPATH/LIAM2-Client.html

printf "
$DOCKERHOSTPROTOKOLL://$HOSTNAME:$DOCKERHOSTPORT\LIAM2-Server.html\n\r
$DOCKERHOSTPROTOKOLL://$HOSTNAME:$DOCKERHOSTPORT\LIAM2-Client.html\n\r
Mailhog http://$HOSTNAME:$EXT_PORT_MAILHOG_HTTP\n\r
docker exec -it $LIAM2_SERVER bash \n\r
docker exec -it $LIAM2_CLIENT bash \n\r
docker exec -it $MARIADB bash \n\r
docker exec -it $MAILHOG bash \n\r
"
#printf "\n\r$LIAM2_ACCEPTANCETEST_VAR \n\r"

#echo "LIAM2_SERVER: "$LIAM2_SERVER
#echo "LIAM2_CLIENT: "$LIAM2_CLIENT
#rm -rf $TMP_DIR

#if [ ! -d "$FOLDER" ] ; then
#   git clone $URL $FOLDER
#else
    #cd "$FOLDER"
    #git pull $URL
#fi

