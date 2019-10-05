#!/bin/bash
var_tmp="<a href=\"http://phpmyadmin"-$var_server_name":"$var_http_proxyport_live"\" target=\"_blank\" rel=\"noopener\">http://phpmyadmin-"$var_server_name":"$var_http_proxyport_live"</a></p></br>"
var_tmp=$var_tmp"<a href=\"http://mailhog-"$var_server_name":"$var_http_proxyport_live"\" target=\"_blank\" rel=\"noopener\">http://mailhog-"$var_server_name":"$var_http_proxyport_live"</a></p></br>"
var_tmp=$var_tmp"mysql -h db-${var_server_name} -u root -p$var_db_rootpasswd -P $var_sql_port</br></br><hr>"
export var_index_live="${var_index_live//PLACEHOLDER-MIDDLE8/"$var_tmp"PLACEHOLDER-MIDDLE8}"