#!/bin/bash
var_tmp=$var_server_name
export var_index_notlive="${var_index_notlive//CARD HEADER/"$var_tmp"}"
var_tmp="<li><a href=\"http://phpmyadmin"-$var_server_name":"$var_http_proxyport_notlive"\" target=\"_blank\" rel=\"noopener\">http://phpmyadmin-"$var_server_name":"$var_http_proxyport_notlive"</a></li>"
var_tmp=$var_tmp"<li>mysql -h db-${var_server_name} -u root -p$var_db_rootpasswd -P $var_sql_port</li>"
var_tmp=$var_tmp"<li><a href=\"http://mailhog-"$var_server_name":"$var_http_proxyport_notlive"\" target=\"_blank\" rel=\"noopener\">http://mailhog-"$var_server_name":"$var_http_proxyport_notlive"</a></li>"
export var_index_notlive="${var_index_notlive//CARD CONTENT/"$var_tmp"}"
export var_index_notlive="${var_index_notlive//NEW CARD/"$var_index_newcard"}"