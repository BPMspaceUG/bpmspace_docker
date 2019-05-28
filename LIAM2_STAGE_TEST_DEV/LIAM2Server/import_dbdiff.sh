#!/bin/bash
mysql -u root -pDB_ROOT_PASSWD -h IP_MARIADB --port 3306 < /var/www/html/sqldump/LIAM2_SQLDUMP_FILE_DIFF
