#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
mkdir -p -- $HOME/tmp
cd $HOME/tmp
TMP_DIR=$HOME/tmp
source $DIR/db.secret.conf
#mysql -u $USER -p$PASS -e 'use bpmspace_coms_v1; show TABLES;'
#mysql -u 'root' -p'VE21LRqRcKCS$brEAIx%!o6l#' -e 'use bpmspace_coms_v1; show TABLES;'
mysqldump -u $USER -p$PASS bpmspace_coms_v1 --databases  --routines > $TMP_DIR/dump_coms_v1_DB_LIVE.sql
cp $TMP_DIR/dump_coms_v1_DB_LIVE.sql $TMP_DIR/dump_coms_v1_DB_STAGE.sql
sed -i 's/bpmspace_coms_v1/bpmspace_coms_v1_STAGE/g' $TMP_DIR/dump_coms_v1_DB_STAGE.sql
cp $DIR/docker-compose.yml $TMP_DIR/docker-compose.yml
sed -i "s/AUTOMATICALLYSET/$PASS/g" $TMP_DIR/docker-compose.yml
sudo docker-compose -f $TMP_DIR/docker-compose.yml up -d
echo "sleep"
sleep 25s
mysql -u root -p$PASS -h 172.28.44.99 --port 3306 < $TMP_DIR/dump_coms_v1_DB_STAGE.sql
mysql -u root -p$PASS -h 172.28.44.99 --port 3306 -e "use bpmspace_coms_v1_STAGE; CALL bpmspace_coms_v1_STAGE.anonymize_coms();"

mysqldump -u root -p$PASS -h 172.28.44.99 --port 3306 --databases bpmspace_coms_v1_STAGE --routines > $TMP_DIR/dump_coms_v1_DB_STAGE_anonymized.sql
cp $TMP_DIR/dump_coms_v1_DB_STAGE.sql $TMP_DIR/dump_coms_v1_DB_TEST.sql
sed -i 's/bpmspace_coms_v1_STAGE/bpmspace_coms_v1_TEST/g' $TMP_DIR/dump_coms_v1_DB_TEST.sql

docker stop MARIADB_TEMP-Server	
docker container rm -v MARIADB_TEMP-Server
sudo docker-compose -f $TMP_DIR/docker-compose.yml up -d
echo "sleep"
sleep 25s

mysql -u root -p$PASS -h 172.28.44.99 --port 3306 < $TMP_DIR/dump_coms_v1_DB_STAGE.sql
mysql -u root -p$PASS -h 172.28.44.99 --port 3306 < $TMP_DIR/dump_coms_v1_DB_TEST.sql


cd $HOME
#sudo rm -rf $HOME/tmp