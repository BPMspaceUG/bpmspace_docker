#!/bin/bash
source $SCRIPT/general.secret.conf
mysqldump -u root -p$DB_ROOT_PASSWD -h $MARIADB -P $EXT_PORT_MARIADB_SQL bpmspace_liam2_v2 state state_rules state_machines >> /var/lib/docker/volumes/DEV-LIAM2-www-data/_data/sqldump/dump_liam2_structure_v2_incl_mindata_DIFF.sql
