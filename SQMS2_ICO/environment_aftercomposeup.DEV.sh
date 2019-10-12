#!/bin/bash
var_tmp=$var_server_name
export var_index_notlive="${var_index_notlive//CARD HEADER/"$var_tmp"}"
var_tmp="<a href=\"http://"$var_server_name":"$var_http_proxyport_notlive"\" target=\"_blank\" rel=\"noopener\">APMS for SQMS2</a></p></br>"
var_tmp=$var_tmp"<a href=\"http://"$var_server_name":"$var_http_proxyport_notlive"\APMS_test\bpmspace_sqms2_v1\" target=\"_blank\" rel=\"noopener\">SQMS2</a></p></br>"
export var_index_notlive="${var_index_notlive//CARD CONTENT/"$var_tmp"}"
export var_index_notlive="${var_index_notlive//NEW CARD/"$var_index_newcard"}"
#git clone https://github.com/BPMspaceUG/APMS2.git .
#mkdir APMS_test
#git clone https://github.com/BPMspaceUG/SQMS2.git /var/www/html/APMS_test/bpmspace_sqms2_v1
#mysql -h db-DEV_BASE.vcap.me -u root -pdorfdepp -P 33060 bpmspace_sqms2_v1 << /var/www/html/APMS_test/bpmspace_sqms2_v1/sqldump/bpmspace_sqms2_v1_structure.sql
#SET FOREIGN_KEY_CHECKS=0;
#mysql -h db-DEV_BASE.vcap.me -u root -pdorfdepp -P 33060 bpmspace_sqms2_v1 << /var/www/html/APMS_test/bpmspace_sqms2_v1/sqldump/pmspace_sqms2_v1_statemachine.sql
#SET FOREIGN_KEY_CHECKS=1;
#chown -R nginx:nginx /var/www/
#find /var/www/ -type f -exec chmod 660 {} \;
# find /var/www/ -type d -exec chmod 770 {} \;
