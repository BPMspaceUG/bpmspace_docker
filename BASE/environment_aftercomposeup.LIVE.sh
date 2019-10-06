#!/bin/bash
var_tmp=$var_server_name
export var_index_live="${var_index_live//CARD HEADER/"$var_tmp"}"
var_tmp="<li><a href=\"http://phpmyadmin"-$var_server_name":"$var_http_proxyport_live"\" target=\"_blank\" rel=\"noopener\">http://phpmyadmin-"$var_server_name":"$var_http_proxyport_live"</a></li>"
var_tmp=$var_tmp"<li>mysql -h db-${var_server_name} -u root -p$var_db_rootpasswd -P $var_sql_port</li>"
var_tmp=$var_tmp"<li><a href=\"http://mailhog-"$var_server_name":"$var_http_proxyport_live"\" target=\"_blank\" rel=\"noopener\">http://mailhog-"$var_server_name":"$var_http_proxyport_live"</a></li>"
export var_index_live="${var_index_live//CARD CONTENT/"$var_tmp"}"
export var_index_live="${var_index_live//NEW CARD/"$var_index_newcard"}"