#!/bin/bash
SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TMP_DIR=$HOME/tmp/$(date +"%m_%d_%Y_%s")

#create TEMP Folder and SUB
mkdir -p -- $TMP_DIR

# create docker
docker volume create --name LIVE-COMS-www-data-anonymous
docker volume create --name LIVE-COMS-www-config-anonymous
docker volume create --name LIVE-COMS-www-data
docker volume create --name LIVE-COMS-www-config

# get credentials of live DB
source $SCRIPT/general.secret.conf

#copy docker-compose to temp - replace parameter from config file - Start enviroment - ORDER of switches IMPORTANT
cp $SCRIPT/COMS_LIVE/docker-compose.yml $TMP_DIR/docker-compose.yml
sed -i "s/MARIADB_ROOT_PASSWD/$MARIADB_ROOT_PASSWD/g" $TMP_DIR/docker-compose.yml
sed -i "s/PREFIX/$PREFIX/g" $TMP_DIR/docker-compose.yml
sed -i "s/DOCKERNETWORK/$DOCKERNETWORK/g" $TMP_DIR/docker-compose.yml
sed -i "s/DOCKERNETMASK/$DOCKERNETMASK/g" $TMP_DIR/docker-compose.yml
sed -i "s/LIAM2_DB_NAME/$LIAM2_DB_NAME/g" $TMP_DIR/docker-compose.yml
sed -i "s/MARIADB_EXT_PORT_SQL/$MARIADB_EXT_PORT_SQL/g" $TMP_DIR/docker-compose.yml
sed -i "s/MARIADB_IP/$MARIADB_IP/g" $TMP_DIR/docker-compose.yml


# START SFTP SERVER
docker run \
    -v LIVE-COMS-www-data-anonymous:/home/anonymous/data \
    -v LIVE-COMS-www-config-anonymous:/home/anonymous/config \
    -p $COMS_SFTP_PORT:22 -d --name $COMS_SFTP_SERVER atmoz/sftp  \
    anonymous:$COMS_SFTP_PASS:1001
docker exec -it $COMS_SFTP_SERVER /bin/sh -c  "chown anonymous /home/anonymous/* && adduser anonymous www-data"

#DUMP DB from Live DB
mysqldump -u $COMS_LIVE_DBUSER -p$COMS_LIVE_DBPASS bpmspace_coms_v1 --databases  --routines > $TMP_DIR/dump_coms_v1_DB_LIVE.sql

#COPY LIVE DUMP to STAGE/TEST DUMPand replace DB Name in both DUMPs
cp $TMP_DIR/dump_coms_v1_DB_LIVE.sql $TMP_DIR/dump_coms_v1_DB_STAGE.sql
cp $TMP_DIR/dump_coms_v1_DB_LIVE.sql $TMP_DIR/dump_coms_v1_DB_TEST_NOTANONYMIZED.sql
sed -i 's/bpmspace_coms_v1/bpmspace_coms_v1_STAGE/g' $TMP_DIR/dump_coms_v1_DB_STAGE.sql
sed -i 's/bpmspace_coms_v1/bpmspace_coms_v1_TEST/g' $TMP_DIR/dump_coms_v1_DB_TEST_NOTANONYMIZED.sql

# prepare yml file, change passwd ,& start TEMP Maria DB Server
sudo docker-compose -f $TMP_DIR/docker-compose.yml up -d

#WAIT until dockers are UP
echo "WAIT until dockers are UP"
#until [ "`docker inspect -f {{.State.Running}} MARIADB_TEMP-Server`"=="true" ]; do
#    echo "."
#	sleep 0.1;
#done;
sleep 50s
#IMPORT STAGE an  NOT anaonymized TESTDB
echo "IMPORT STAGE STARTS"
mysql -u root -p$MARIADB_ROOT_PASSWD -h $MARIADB_IP --port 3306 < $TMP_DIR/dump_coms_v1_DB_STAGE.sql
echo "IMPORT TEST STARTS"
mysql -u root -p$MARIADB_ROOT_PASSWD -h $MARIADB_IP --port 3306 < $TMP_DIR/dump_coms_v1_DB_TEST_NOTANONYMIZED.sql

# CAll anonymize ONLY on TEST
echo "ANONYMIZE TEST STARTS"
mysql -u root -p$MARIADB_ROOT_PASSWD -h $MARIADB_IP --port 3306 -e "use bpmspace_coms_v1_TEST; CALL bpmspace_coms_v1_TEST.anonymize_coms();"
# TEST IF DUMP IS anonymized else exit

#Export TEST and remove not anonymzed TEST DUMP
echo "EXPORT TEST STARTS"
mysqldump -u root -p$MARIADB_ROOT_PASSWD -h $MARIADB_IP --port 3306 --databases bpmspace_coms_v1_TEST --routines > $TMP_DIR/dump_coms_v1_DB_TEST.sql
rm $TMP_DIR/dump_coms_v1_DB_TEST_NOTANONYMIZED.sql
echo "done ... "

# tar COMS Pfad inkl certificates
# tar COMS Pfad EXCL certificates
# TEST IF TAR is anonimized
docker cp $TMP_DIR/dump_coms_v1_DB_TEST.sql $COMS_SFTP_SERVER:home/anonymous/data


# PREFIX="STAGE"
# Source create_LIAM2.sh
# Source create_COMS.sh


cd $HOME
#sudo rm -rf $TMP_DIR
