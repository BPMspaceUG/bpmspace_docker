#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TMP_DIR=$HOME/tmp/$(date +"%m_%d_%Y_%s")
mkdir -p -- $TMP_DIR
cd $TMP_DIR

# get credentials of live DB
source $DIR/db.secret.conf

#DUMP DB from Live DB
mysqldump -u $USER -p$PASS bpmspace_coms_v1 --databases  --routines > $TMP_DIR/dump_coms_v1_DB_LIVE.sql

#COPY LIVE DUMP to STAGE/TEST DUMPand replace DB Name in both DUMPs
cp $TMP_DIR/dump_coms_v1_DB_LIVE.sql $TMP_DIR/dump_coms_v1_DB_STAGE.sql
cp $TMP_DIR/dump_coms_v1_DB_LIVE.sql $TMP_DIR/dump_coms_v1_DB_TEST_NOTANONYMIZED.sql
sed -i 's/bpmspace_coms_v1/bpmspace_coms_v1_STAGE/g' $TMP_DIR/dump_coms_v1_DB_STAGE.sql
sed -i 's/bpmspace_coms_v1/bpmspace_coms_v1_TEST/g' $TMP_DIR/dump_coms_v1_DB_TEST_NOTANONYMIZED.sql

# prepare yml file, change passwd ,& start TEMP Maria DB Server
cp $DIR/docker-compose.yml $TMP_DIR/docker-compose.yml
sed -i "s/AUTOMATICALLYSET/$PASS/g" $TMP_DIR/docker-compose.yml
sudo docker-compose -f $TMP_DIR/docker-compose.yml up -d

#WAIT until dockers are UP
echo "WAIT until dockers are UP"
#until [ "`docker inspect -f {{.State.Running}} MARIADB_TEMP-Server`"=="true" ]; do
#    echo "."
#	sleep 0.1;
#done;
sleep 25s
#IMPORT STAGE an  NOT anaonymized TESTDB
echo "IMPORT STAGE STARTS"
mysql -u root -p$PASS -h 172.28.44.99 --port 3306 < $TMP_DIR/dump_coms_v1_DB_STAGE.sql
echo "IMPORT TEST STARTS"
mysql -u root -p$PASS -h 172.28.44.99 --port 3306 < $TMP_DIR/dump_coms_v1_DB_TEST_NOTANONYMIZED.sql

# CAll anonymize ONLY on TEST
echo "ANONYMIZE TEST STARTS"
mysql -u root -p$PASS -h 172.28.44.99 --port 3306 -e "use bpmspace_coms_v1_TEST; CALL bpmspace_coms_v1_TEST.anonymize_coms();"

#Export TEST and remove not anonymzed TEST DUMP
echo "EXPORT TEST STARTS"
mysqldump -u root -p$PASS -h 172.28.44.99 --port 3306 --databases bpmspace_coms_v1_TEST --routines > $TMP_DIR/dump_coms_v1_DB_TEST.sql
rm $TMP_DIR/dump_coms_v1_DB_TEST_NOTANONYMIZED.sql
echo "done ... "
docker ps

#docker stop MARIADB_TEMP-Server	
#docker container rm -v MARIADB_TEMP-Server
#sudo docker-compose -f $TMP_DIR/docker-compose.yml up -d
#echo "sleep"
#sleep 25s

#mysql -u root -p$PASS -h 172.28.44.99 --port 3306 < $TMP_DIR/dump_coms_v1_DB_STAGE.sql
#mysql -u root -p$PASS -h 172.28.44.99 --port 3306 < $TMP_DIR/dump_coms_v1_DB_TEST.sql


cd $HOME
#sudo rm -rf $TMP_DIR