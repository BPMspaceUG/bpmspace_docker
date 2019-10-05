#!/bin/bash
var_tmp="<a href=\"http://"$var_server_name":"$var_http_proxyport_notlive"\" target=\"_blank\" rel=\"noopener\">http://"$var_server_name":"$var_http_proxyport_notlive"</a></p></br>"
var_index_live="${var_index_live//PLACEHOLDER-MIDDLE8/"$var_tmp"PLACEHOLDER-MIDDLE8}"