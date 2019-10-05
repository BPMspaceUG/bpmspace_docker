#!/bin/bash
var_tmp="<a href=\"http://phpmyadmin"-$var_server_name":"$var_http_proxyport_notlive"\" target=\"_blank\" rel=\"noopener\">http://phpmyadmin-"$var_server_name":"$var_http_proxyport_notlive"</a></p></br>"
var_tmp=$var_tmp"<a href=\"http://mailhog-"$var_server_name":"$var_http_proxyport_notlive"\" target=\"_blank\" rel=\"noopener\">http://mailhog-"$var_server_name":"$var_http_proxyport_notlive"</a></p></br>"
var_tmp=$var_tmp"mysql -h db-${var_server_name} -u root -p$var_db_rootpasswd -P $var_sql_port</br></br><hr>"
var_index_notlive="${var_index_notlive//PLACEHOLDER-MIDDLE8/"$var_tmp"PLACEHOLDER-MIDDLE8}"