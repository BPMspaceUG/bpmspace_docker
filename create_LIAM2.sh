#!/bin/bash
SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TMP_DIR=/tmp/$(date +"%m_%d_%Y_%s")

#create TEMP Folder and SUB
mkdir -p -- $TMP_DIR
mkdir -p -- $TMP_DIR/_bpmspace_base
mkdir -p -- $TMP_DIR/LIAM2-SERVER-html/
mkdir -p -- $TMP_DIR/LIAM2-CLIENT-html/
mkdir -p -- $TMP_DIR/COMS-CLIENT2-html/

cd $TMP_DIR
# get (secret) parameters
source $SCRIPT/general.secret.conf

############TODO - TEST IF PREFIX="STAGE"|"TEST"|"DEV"|TESTDEV or exit https://rsalveti.wordpress.com/2007/04/03/bash-parsing-arguments-with-getopts/

LIAM2_SERVER=$(echo "$PREFIX" | tr '[:upper:]' '[:lower:]')"_liam2-php-apache_1"
LIAM2_CLIENT=$(echo "$PREFIX" | tr '[:upper:]' '[:lower:]')"_liam2-client-php-apache_1"
COMS_CLIENT2=$(echo "$PREFIX" | tr '[:upper:]' '[:lower:]')"_coms-client2-php-apache_1"
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
docker volume create --name $PREFIX-COMS-CLIENT2-www-data
docker volume create --name $PREFIX-COMS-CLIENT2-www-config
docker volume create --name $PREFIX-mariadb-data
docker volume create --name $PREFIX-mariadb-config
docker volume create --name $PREFIX-mailhog-data
docker volume create --name $PREFIX-mailhog-config

#download DB LIAM2 Structure and minimum Data
# wget --no-hsts $LIAM2_SQLDUMP_URL$LIAM2_SQLDUMP_FILE -P $TMP_DIR

# download git LIAM2 and LIAM2-client in a temp HTML dir + change owner
git clone $LIAM2_GITHUB_REPO_URL $TMP_DIR/LIAM2-SERVER-html/
git clone $LIAM2_CLIENT_GITHUB_REPO_URL $TMP_DIR/LIAM2-CLIENT-html/
git clone $COMS_CLIENT2_GITHUB_REPO_URL $TMP_DIR/COMS-CLIENT2-html/

# copy LIAM config to HTML temp  Folder + replace Parameters
cp $SCRIPT/LIAM2_STAGE_TEST_DEV/LIAM2Server/bpmspace_liam2_v2-config_EXAMPLEsecret.inc.php $TMP_DIR/LIAM2-SERVER-html/bpmspace_liam2_v2-config.secret.inc.php
sed -i "s/MARIADB_ROOT_PASSWD/$MARIADB_ROOT_PASSWD/g" $TMP_DIR/LIAM2-SERVER-html/bpmspace_liam2_v2-config.secret.inc.php
sed -i "s/MARIADB_IP/$MARIADB_IP/g" $TMP_DIR/LIAM2-SERVER-html/bpmspace_liam2_v2-config.secret.inc.php
sed -i "s/LIAM2_DB_NAME/$LIAM2_DB_NAME/g" $TMP_DIR/LIAM2-SERVER-html/bpmspace_liam2_v2-config.secret.inc.php
sed -i "s/EXT_PORT_LIAM2_HTTP/$EXT_PORT_LIAM2_HTTP/g" $TMP_DIR/LIAM2-SERVER-html/bpmspace_liam2_v2-config.secret.inc.php
sed -i "s/HOSTNAME/$HOSTNAME/g" $TMP_DIR/LIAM2-SERVER-html/bpmspace_liam2_v2-config.secret.inc.php

# copy LIAM CLIENT config to temp HTML dir
cp $SCRIPT/LIAM2_STAGE_TEST_DEV/LIAM2Client/LIAM2_Client_api_EXAMPLEsecret.inc.php $TMP_DIR/LIAM2_Client_api.secret.inc.php
sed -i "s/LIAM2_IP/$LIAM2_IP/g" $TMP_DIR/LIAM2_Client_api.secret.inc.php
sudo cp $TMP_DIR/LIAM2_Client_api.secret.inc.php $TMP_DIR/LIAM2-CLIENT-html/inc
sudo chown -R www-data:www-data $TMP_DIR/LIAM2-CLIENT-html/

# copy COMS CLIENT2 config to temp HTML dir
cp $SCRIPT/LIAM2_STAGE_TEST_DEV/COMS_Client2/COMS_Client2_api_EXAMPLEsecret.inc.php $TMP_DIR/COMS_Client2_api.secret.inc.php
sed -i "s/LIAM2_IP/$LIAM2_IP/g" $TMP_DIR/COMS_Client2_api.secret.inc.php
sed -i "s/COMS_URL/$COMS_URL/g" $TMP_DIR/COMS_Client2_api.secret.inc.php
sudo cp $TMP_DIR/LIAM2_Client_api.secret.inc.php $TMP_DIR/LIAM2-CLIENT-html/inc
sudo chown -R www-data:www-data $TMP_DIR/COMS_Client2_api.secret.inc.php

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
sed -i "s/EXT_PORT_COMS_CLIENT2_HTTPS/$EXT_PORT_COMS_CLIENT2_HTTPS/g" $TMP_DIR/docker-compose.yml
sed -i "s/EXT_PORT_COMS_CLIENT2_HTTP/$EXT_PORT_COMS_CLIENT2_HTTP/g" $TMP_DIR/docker-compose.yml
sed -i "s/COMS_IP_CLIENT/$COMS_IP_CLIENT/g" $TMP_DIR/docker-compose.yml
sed -i "s/EXT_PORT_LIAM2_CLIENT_HTTPS/$EXT_PORT_LIAM2_CLIENT_HTTPS/g" $TMP_DIR/docker-compose.yml
sed -i "s/EXT_PORT_LIAM2_CLIENT_HTTP/$EXT_PORT_LIAM2_CLIENT_HTTP/g" $TMP_DIR/docker-compose.yml
sed -i "s/LIAM2_IP_CLIENT/$LIAM2_IP_CLIENT/g" $TMP_DIR/docker-compose.yml
sed -i "s/EXT_PORT_LIAM2_HTTPS/$EXT_PORT_LIAM2_HTTPS/g" $TMP_DIR/docker-compose.yml
sed -i "s/EXT_PORT_LIAM2_HTTP/$EXT_PORT_LIAM2_HTTP/g" $TMP_DIR/docker-compose.yml
sed -i "s/LIAM2_IP/$LIAM2_IP/g" $TMP_DIR/docker-compose.yml
sed -i "s/PHPMYADMIN_IP/$PHPMYADMIN_IP/g" $TMP_DIR/docker-compose.yml
sed -i "s/EXT_PORT_PHPMYADMIN_HTTP/$EXT_PORT_PHPMYADMIN_HTTP/g" $TMP_DIR/docker-compose.yml

# prepare LIAM SERVER Acceptance Mail 
wget --no-hsts $LIAM2_SERVER_ACCEPTANCETEST_URL/$LIAM2_SERVER_ACCEPTANCETEST_FILE -P $TMP_DIR
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

# prepare LIAM CLIENT Acceptance Mail 
wget --no-hsts $LIAM2_CLIENT_ACCEPTANCETEST_URL/$LIAM2_CLIENT_ACCEPTANCETEST_FILE -P $TMP_DIR
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


#config Mail relay & restart Postfix and send testmail
docker cp $SCRIPT/_bpmspace_base/main.cf $LIAM2_SERVER:/etc/postfix/main.cf
docker cp $SCRIPT/_bpmspace_base/main.cf $LIAM2_CLIENT:/etc/postfix/main.cf
docker cp $SCRIPT/_bpmspace_base/main.cf $COMS_CLIENT2:/etc/postfix/main.cf

# copy php.ini
docker cp $SCRIPT/_bpmspace_base/php.ini $LIAM2_SERVER:/usr/local/etc/php/php.ini
docker cp $SCRIPT/_bpmspace_base/php.ini $LIAM2_CLIENT:/usr/local/etc/php/php.ini
docker cp $SCRIPT/_bpmspace_base/php.ini $COMS_CLIENT2:/usr/local/etc/php/php.ini

#copy temp html dir to docker
docker cp $TMP_DIR/LIAM2-SERVER-html/. $LIAM2_SERVER:/var/www/html
docker cp $TMP_DIR/LIAM2-CLIENT-html/. $LIAM2_CLIENT:/var/www/html
docker cp $TMP_DIR/COMS-CLIENT2-html/. $COMS_CLIENT2:/var/www/html

#prepare fetch all command and copy to contaier
echo "prepare fetch all command"
cp $SCRIPT/_bpmspace_base/fetch_all.php $TMP_DIR/fetch_all.php
cp $SCRIPT/_bpmspace_base/fetch_all.sh $TMP_DIR/fetch_all.sh
echo "copy fetch all command"
docker exec -it $LIAM2_SERVER /bin/sh -c  "mkdir -p -- /var/www/script/"
docker exec -it $LIAM2_SERVER /bin/sh -c  "mkdir -p -- /var/www/html/release_cmd/"
docker cp $TMP_DIR/fetch_all.php $LIAM2_SERVER:/var/www/html/release_cmd/fetch_all.php
docker cp $TMP_DIR/fetch_all.sh $LIAM2_SERVER:/var/www/script/fetch_all.sh

docker exec -it $LIAM2_CLIENT /bin/sh -c  "mkdir -p -- /var/www/script/"
docker exec -it $LIAM2_CLIENT /bin/sh -c  "mkdir -p -- /var/www/html/release_cmd/"
docker cp $TMP_DIR/fetch_all.php $LIAM2_CLIENT:/var/www/html/release_cmd/fetch_all.php
docker cp $TMP_DIR/fetch_all.sh $LIAM2_CLIENT:/var/www/script/fetch_all.sh

docker exec -it $COMS_CLIENT2 /bin/sh -c  "mkdir -p -- /var/www/script/"
docker exec -it $COMS_CLIENT2 /bin/sh -c  "mkdir -p -- /var/www/html/release_cmd/"
docker cp $TMP_DIR/fetch_all.php $COMS_CLIENT2:/var/www/html/release_cmd/fetch_all.php
docker cp $TMP_DIR/fetch_all.sh $COMS_CLIENT2:/var/www/script/fetch_all.sh

#prepare DB import command
echo "prepare DB import command"
cp $SCRIPT/LIAM2_STAGE_TEST_DEV/LIAM2Server/import_db.php $TMP_DIR/import_db.php
cp $SCRIPT/LIAM2_STAGE_TEST_DEV/LIAM2Server/import_db.sh $TMP_DIR/import_db.sh
cp $SCRIPT/LIAM2_STAGE_TEST_DEV/LIAM2Server/import_dbdiff.php $TMP_DIR/import_dbdiff.php
cp $SCRIPT/LIAM2_STAGE_TEST_DEV/LIAM2Server/import_dbdiff.sh $TMP_DIR/import_dbdiff.sh
#prepare DB modyfy parameter
echo "prepare DB modyfy parameter"
sed -i "s/MARIADB_ROOT_PASSWD/$MARIADB_ROOT_PASSWD/g" $TMP_DIR/import_db.sh
sed -i "s/MARIADB_ROOT_PASSWD/$MARIADB_ROOT_PASSWD/g" $TMP_DIR/import_dbdiff.sh
sed -i "s/MARIADB_IP/$MARIADB_IP/g" $TMP_DIR/import_db.sh
sed -i "s/MARIADB_IP/$MARIADB_IP/g" $TMP_DIR/import_dbdiff.sh
sed -i "s/LIAM2_SQLDUMP_FILE/$LIAM2_SQLDUMP_FILE/g" $TMP_DIR/import_db.sh
sed -i "s/LIAM2_SQLDUMP_FILE_DIFF/$LIAM2_SQLDUMP_FILE_DIFF/g" $TMP_DIR/import_dbdiff.sh

: '
echo "sleep 5s until enviroment is up"
for i in {5..1}
		do echo -e "\r"&& echo -n "$i." && sleep 1
		done
'

#copy DB import script to container
echo "copy DB import script to container"
docker cp $TMP_DIR/import_db.php $LIAM2_SERVER:/var/www/html/release_cmd/import_db.php
docker cp $TMP_DIR/import_dbdiff.php $LIAM2_SERVER:/var/www/html/release_cmd/import_dbdiff.php
docker cp $TMP_DIR/import_db.sh $LIAM2_SERVER:/var/www/script/import_db.sh
docker cp $TMP_DIR/import_dbdiff.sh $LIAM2_SERVER:/var/www/script/import_dbdiff.sh


# Restart Mail server and send testmail
echo "config Mailserver and Send Testmail"
 docker exec -it $LIAM2_SERVER /bin/sh -c  "service postfix stop"
 docker exec -it $LIAM2_SERVER /bin/sh -c  "rm -f /var/spool/postfix/pid/master.pid"
 docker exec -it $LIAM2_SERVER /bin/sh -c  "service postfix start"
 docker exec -it $LIAM2_SERVER /bin/sh -c  "php -r 'mail(\"mailhog@bpmspace.net\", \"TEST from LIAM2_SERVER\", date(DATE_RFC822), \"From: liam2 <liam2@bpmspace.net>\");'"
 docker exec -it $LIAM2_CLIENT /bin/sh -c  "service postfix stop"
 docker exec -it $LIAM2_CLIENT /bin/sh -c  "rm -f /var/spool/postfix/pid/master.pid"
 docker exec -it $LIAM2_CLIENT /bin/sh -c  "service postfix start"
 docker exec -it $LIAM2_CLIENT /bin/sh -c  "php -r 'mail(\"mailhog@bpmspace.net\", \"TEST from LIAM2_CLIENT\", date(DATE_RFC822), \"From: liam2-client <liam2-client@bpmspace.net>\");'"
 docker exec -it $COMS_CLIENT2 /bin/sh -c  "service postfix stop"
 docker exec -it $COMS_CLIENT2 /bin/sh -c  "rm -f /var/spool/postfix/pid/master.pid"
 docker exec -it $COMS_CLIENT2 /bin/sh -c  "service postfix start"
 docker exec -it $COMS_CLIENT2 /bin/sh -c  "php -r 'mail(\"mailhog@bpmspace.net\", \"TEST from COMS_CLIENT2\", date(DATE_RFC822), \"From: coms-client2 <coms-client2@bpmspace.net>\");'"

 # import DB
echo "IMPORT DB on LIAM2"
docker exec -it $LIAM2_SERVER /bin/sh -c  "/var/www/script/import_db.sh"
echo "IMPORT done"
# git fetch all - reset repos 
echo "git fetch all - reset repos"
docker exec -it $LIAM2_SERVER /bin/sh -c  "cd /var/www/html/ && git fetch --all && git reset --hard origin/master"
docker exec -it $LIAM2_CLIENT /bin/sh -c  "cd /var/www/html/ && git fetch --all && git reset --hard origin/master"
docker exec -it $LIAM2_CLIENT /bin/sh -c  "cd /var/www/html/ && git fetch --all && git reset --hard origin/master"

# set owner and execute 
echo "set owner and execute"
docker exec -it $LIAM2_SERVER /bin/sh -c  "chown -R www-data:www-data /var/www/"
docker exec -it $LIAM2_SERVER /bin/sh -c  "find /var/www/html -type f -exec chmod 660 {} \;"
docker exec -it $LIAM2_SERVER /bin/sh -c  "find /var/www/html -type d -exec chmod 770 {} \;"
docker exec -it $LIAM2_SERVER /bin/sh -c  "find /var/www/script -type f -exec chmod 600 {} \;"
docker exec -it $LIAM2_SERVER /bin/sh -c  "find /var/www/script -type d -exec chmod 700 {} \;"
docker exec -it $LIAM2_SERVER /bin/sh -c  "chmod +x /var/www/script/*.sh"
docker exec -it $LIAM2_CLIENT /bin/sh -c  "chown -R www-data:www-data /var/www/"
docker exec -it $LIAM2_CLIENT /bin/sh -c  "find /var/www/html -type f -exec chmod 660 {} \;"
docker exec -it $LIAM2_CLIENT /bin/sh -c  "find /var/www/html -type d -exec chmod 770 {} \;"
docker exec -it $LIAM2_CLIENT /bin/sh -c  "find /var/www/script -type f -exec chmod 660 {} \;"
docker exec -it $LIAM2_CLIENT /bin/sh -c  "find /var/www/script -type d -exec chmod 770 {} \;"
docker exec -it $LIAM2_CLIENT /bin/sh -c  "chmod +x /var/www/script/*.sh"

docker exec -it $COMS_CLIENT2 /bin/sh -c  "chown -R www-data:www-data /var/www/"
docker exec -it $COMS_CLIENT2 /bin/sh -c  "find /var/www/html -type f -exec chmod 660 {} \;"
docker exec -it $COMS_CLIENT2 /bin/sh -c  "find /var/www/html -type d -exec chmod 770 {} \;"
docker exec -it $COMS_CLIENT2 /bin/sh -c  "find /var/www/script -type f -exec chmod 660 {} \;"
docker exec -it $COMS_CLIENT2 /bin/sh -c  "find /var/www/script -type d -exec chmod 770 {} \;"
docker exec -it $COMS_CLIENT2 /bin/sh -c  "chmod +x /var/www/script/*.sh"

ENVIROMENTDESC="<h1>Test Protokoll</h1>
<ul>
<li><a href=\"$DOCKERHOSTPROTOKOLL://$HOSTNAME:$DOCKERHOSTPORT\index.html\" target=\"_blank\" rel=\"noopener\">this Page</a></li>
<li><a href=\"$DOCKERHOSTPROTOKOLL://$HOSTNAME:$DOCKERHOSTPORT\LIAM2\Server\AcceptanceTest.html\" target=\"_blank\" rel=\"noopener\">LIAM2 AcceptanceTest</a></li>
<li><a href=\"$DOCKERHOSTPROTOKOLL://$HOSTNAME:$DOCKERHOSTPORT\LIAM2\Client\AcceptanceTest.html\" target=\"_blank\" rel=\"noopener\">LIAM2 Client AcceptanceTest</a></li>
</ul>
<h2>Mail Server</h2>
<ul>
<li><a href=\"http://$HOSTNAME:$EXT_PORT_MAILHOG_HTTP \">MAILHOG Catch all Server </a></li>
</ul>
<h2>MariaDB</h2>
<ul>
<li>mysql -u root -p$MARIADB_ROOT_PASSWD -h $HOSTNAME -P $MARIADB_EXT_PORT_SQL - MYPHPADMIN</li>
<li><a href=\"http://$HOSTNAME:$EXT_PORT_PHPMYADMIN_HTTP?pma_username=root&amp;pma_password$MARIADB_ROOT_PASSWD\"> PHP my Admin</a></li>
</ul>
<h2>LIAM2 Server</h2>
<ul>
<li><a href=\"http://$HOSTNAME:$EXT_PORT_LIAM2_HTTP \">LIAM2 Server</a></li>
<li><a href=\"http://$HOSTNAME:$EXT_PORT_LIAM2_HTTP/release_cmd/fetch_all.php\">LIAM2 Server FETCH ALL</a></li>
<li><a href=\"http://$HOSTNAME:$EXT_PORT_LIAM2_HTTP/release_cmd/import_db.php \">LIAM2 Server IMPORT ALL </a></li>
<li><a href=\"http://$HOSTNAME:$EXT_PORT_LIAM2_HTTP/release_cmd/import_dbdiff.php \">LIAM2 Server IMPORT DIFF</a></li>
</ul>
<h2>LIAM2 Client</h2>
<ul>
<li><a href=\"http://$HOSTNAME:$EXT_PORT_LIAM2_CLIENT_HTTP \">LIAM2 Client</a></li>
<li><a href=\"http://$HOSTNAME:$EXT_PORT_LIAM2_CLIENT_HTTP/release_cmd/fetch_all.php\">LIAM2 Client FETCH ALL</a></li>
</ul>
<h2>COMS Client2</h2>
<ul>
<li><a href=\"http://$HOSTNAME:$EXT_PORT_COMS_CLIENT2_HTTP \">COMS Client2</a></li>
<li><a href=\"http://$HOSTNAME:$EXT_PORT_COMS_CLIENT2_HTTP/release_cmd/fetch_all.php\">COMS Client2 FETCH ALL</a></li>
</ul>
<h2>Docker Commands</h2>
<ul>
<li>docker exec -it $LIAM2_SERVER bash</li>
<li>docker logs $LIAM2_SERVER</li>
<li>docker exec -it $LIAM2_CLIENT bash</li>
<li>docker logs $LIAM2_CLIENT</li>
<li>docker exec -it $MARIADB bash</li>
<li>docker logs $MARIADB</li>
<li>docker exec -it phpmyadmin bash</li>
<li>docker logs phpmyadmin</li>
<li>docker exec -it $MAILHOG bash</li>
<li>docker logs $MAILHOG\"</li>
</ul>"

	
# prepare Enviroment 
echo "prepare Enviroment"s
sudo mkdir -p -- $DOCKERHOSTWWWPATH/LIAM2
sudo mkdir -p -- $DOCKERHOSTWWWPATH/LIAM2/Script
sudo mkdir -p -- $DOCKERHOSTWWWPATH/LIAM2/Server
sudo mkdir -p -- $DOCKERHOSTWWWPATH/LIAM2/Client
sudo touch $DOCKERHOSTWWWPATH/LIAM2/Server/AcceptanceTest.html
sudo touch $DOCKERHOSTWWWPATH/LIAM2/Client/AcceptanceTest.html
sudo echo $ENVIROMENTDESC > $DOCKERHOSTWWWPATH/index.html
sudo markdown $TMP_DIR/$LIAM2_SERVER_ACCEPTANCETEST_FILE > $DOCKERHOSTWWWPATH/LIAM2/Server/AcceptanceTest.html
sudo markdown $TMP_DIR/$LIAM2_CLIENT_ACCEPTANCETEST_FILE > $DOCKERHOSTWWWPATH/LIAM2/Client/AcceptanceTest.html
sudo cp $SCRIPT/create_LIAM2.sh /usr/lib/cgi-bin
sudo cp $SCRIPT/LIAM2_STAGE_TEST_DEV/create_LIAM2.php $DOCKERHOSTWWWPATH/LIAM2/
sudo chown -R www-data:www-data $DOCKERHOSTWWWPATH/LIAM2/
sudo find $DOCKERHOSTWWWPATH/LIAM2 -type f -exec chmod 660 {} \;
sudo find $DOCKERHOSTWWWPATH/LIAM2 -type d -exec chmod 770 {} \;
sudo chown -R www-data:www-data /usr/lib/cgi-bin/*.sh
sudo chmod +x /usr/lib/cgi-bin/*.sh

echo "more info under $DOCKERHOSTPROTOKOLL://$HOSTNAME:$DOCKERHOSTPORT\index.html"
#sudo rm $TMP_DIR
cd $HOME


