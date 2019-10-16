#!/bin/bash
maxcounter=20
counter=1
while ! mysql --protocol TCP -u root -pMARIADB_ROOT_PASSWD -h MARIADB_IP --port 3306 -e "show databases;" > /dev/null 2>&1; do
    sleep 1
	echo "$counter - I try to connect please wait"
    counter=`expr $counter + 1`
    if [ $counter -gt $maxcounter ]; then
        >&2 echo "We have been waiting for MySQL too long already; failing."
        exit 1
    fi;
done
#mysql -u root -pMARIADB_ROOT_PASSWD -h MARIADB_IP --port 3306 < /var/www/html/sqldump/LIAM2_SQLDUMP_FILE
mysql -u root -pMARIADB_ROOT_PASSWD -h MARIADB_IP --port 3306  -e "DROP DATABASE IF EXISTS bpmspace_liam2_v2;"
mysql -u root -pMARIADB_ROOT_PASSWD -h MARIADB_IP --port 3306  -e "CREATE DATABASE bpmspace_liam2_v2 /*!40100 DEFAULT CHARACTER SET utf8 */;"
mysql -u root -pMARIADB_ROOT_PASSWD -h MARIADB_IP --port 3306  -e "USE bpmspace_liam2_v2;"
mysql -u root -pMARIADB_ROOT_PASSWD -h MARIADB_IP --port 3306  -e "SET FOREIGN_KEY_CHECKS=0;"
echo "DB import bpmspace_liam2_v2_structure"
mysql -u root -pMARIADB_ROOT_PASSWD -h MARIADB_IP --port 3306 bpmspace_liam2_v2 < /var/www/html/sqldump/bpmspace_liam2_v2_structure.sql
echo "DB import bpmspace_liam2_v2_statemachine"
mysql -u root -pMARIADB_ROOT_PASSWD -h MARIADB_IP --port 3306 bpmspace_liam2_v2 < /var/www/html/sqldump/bpmspace_liam2_v2_statemachine.sql
echo "DB import bpmspace_liam2_v2_mindata"
mysql -u root -pMARIADB_ROOT_PASSWD -h MARIADB_IP --port 3306 bpmspace_liam2_v2 < /var/www/html/sqldump/bpmspace_liam2_v2_mindata.sql
echo "DB import done"
mysql -u root -pMARIADB_ROOT_PASSWD -h MARIADB_IP --port 3306  -e "SET FOREIGN_KEY_CHECKS=1;"