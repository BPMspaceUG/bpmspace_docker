#!/bin/bash
var_tmp=$var_server_name
export var_index_notlive="${var_index_notlive//CARD HEADER/"$var_tmp"}"
var_tmp="<a href=\"http://www-"$var_server_name":"$var_http_proxyport_notlive"\" target=\"_blank\" rel=\"noopener\">http://www-"$var_server_name":"$var_http_proxyport_notlive"</a></p></br>"
export var_index_notlive="${var_index_notlive//CARD CONTENT/"$var_tmp"}"
export var_index_notlive="${var_index_notlive//NEW CARD/"$var_index_newcard"}"