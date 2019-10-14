#!/bin/bash
var_tmp=$var_server_name
export var_index_live="${var_index_live//CARD HEADER/"$var_tmp"}"
var_tmp="<a href=\"http://server-"$var_server_name":"$var_http_proxyport_live"\" target=\"_blank\" rel=\"noopener\">http://server-"$var_server_name":"$var_http_proxyport_live"</a></p></br>"
export var_index_live="${var_index_live//CARD CONTENT/"$var_tmp"}"
export var_index_live="${var_index_live//NEW CARD/"$var_index_newcard"}"
