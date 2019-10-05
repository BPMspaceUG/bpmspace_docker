#!/bin/bash
var_script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
var_temp_dir=/tmp/$(date +"%m_%d_%Y_%s")

# get (secret) parameters
source $var_script_path/setup_environment.secret.conf

if [ $# -gt 0 ]; then
    echo "Your command line contains $# arguments"
else
    echo "Your command line contains no arguments"
fi

usage() {
	echo error $1
}

create_docker_volumes() {
	docker volume create --name $1-$2-data
	docker volume create --name $1-$2-config
	docker volume create --name $1-$2-backup
}

create_docker_network() {
	docker network create nginx-proxy
	docker network create base
}

# default Values
# nslookup to soemthing.vcap.me returns 127.0.0.1 
export var_base="vcap.me"
export var_steps_all=true
export var_typ_all=true
#var_environment=( "BASE" "LIAM2_ICO" "SQMS_ICO" "SQMS_EXPORT" "SQMS2_ICO" "COMS_ICO" "BWNG_MITSM" "WWW_BPMSPACE" "WWW_ICO" "WWW_MITSM" "MOODLE_ICO" )
export var_environment=( "BASE" "LIAM2_ICO"  )
export var_typ=( "LIVE" "TEST" "DEV" )
export var_release_full=true
export var_release_delta=false

export var_http_proxyport_live=8087
export var_https_proxyport_live=8043
export var_http_proxyport_notlive=8088
export var_https_proxyport_notlive=8044

export var_sql_port_default=33060
export var_sql_port=$var_sql_port_default
export var_smtp_port_default=1025
export var_smtp_port=$var_smtp_port_default
export var_httpmail_port_default=8025
export var_httpmail_port=$var_httpmail_port_default

export var_http_port=10080
export var_https_port=10443

export var_db_rootpasswd="dorfdepp"


while [ "$1" != "" ]; do
    case $1 in
        -S | --steps )     		shift
								var_temp_arguments=${1^^}
								var_steps_all=false
                                case $var_temp_arguments in
									"ALL"  )
										var_steps_all=true
										;;
									"VOLUMES"  )
										var_steps_vol=true
										;;
									"COMPOSE"  )
										var_steps_com=true
										;;
									"RUN"  )
										var_steps_run=true
										;;
									"SQL"  )
										var_steps_sql=true
										;;
									"GIT"  )
										var_steps_git=true
										;;
									* )
										usage steps
										exit 1
								esac
                                ;;
        -E | --environment )     shift
								var_environment=()
								while [ "$1" != "" ]
								do
									var_temp_arguments=${1^^}
									case $var_temp_arguments in
										"ALL"  )
											var_environment=(  "BASE" "LIAM2_ICO" "SQMS_ICO" "SQMS_EXPORT" "SQMS2_ICO" "COMS_ICO"  "BWNG_MITSM" "WWW_BPMSPACE" "WWW_ICO" "WWW_MITSM" "MOODLE_ICO"  )
											;;
										"BASE"   )
											var_environment+=( "BASE" )
											;;
										"LIAM2_ICO"  )
											var_environment+=( "LIAM2_ICO" )
											;;
										"SQMS_ICO"  )
											var_environment+=( "SQMS_ICO" )
											;;
										"SQMS_EXPORT"  )
											var_environment+=( "SQMS_EXPORT" )
											;;
										"SQMS2_ICO"  )
											var_environment+=( "SQMS2_ICO" )
											;;
										"COMS_ICO" )
											var_environment+=( "COMS_ICO" )
											;;
										"BWNG_MITSM" )
											var_environment+=( "BWNG_MITSM" )
											;;
										"WWW_BPMSPACE" )
											var_environment+=( "WWW_BPMSPACE" )
											;;
										"WWW_ICO" )
											var_environment+=( "WWW_ICO" )
											;;
										"WWW_MITSM" )
											var_environment+=( "WWW_MITSM" )
											;;
										"MOODLE_ICO" )
											var_environment+=( "MOODLE_ICO" )
											;;
										* )
											usage environment
											exit 1
									esac
									if [[ $2 == "-"* ]] || [[ $2 == "" ]]; then
										break
									fi
									shift
								done
                                ;;
        -T | --typ )         	shift
								var_typ=()
								var_typ_all=false
								while [ "$1" != "" ]
								do
									var_temp_arguments=${1^^}
									case $var_temp_arguments in
										"ALL")
											var_typ=( "LIVE" "REF" "STAGE" "TEST" "DEV" )
											var_typ_all=true
											;;
										"LIVE")
											var_typ+=( "LIVE")
											var_step_live=true
											;;
										"REF")
											var_typ+=( "REF" )
											;;
										"STAGE")
											var_typ+=( "STAGE" )
											;;
										"TEST")
											var_typ+=( "TEST" )
											;;
										"DEV")
											var_typ+=( "DEV" )
											var_step_dev=true
											;;
										* )
											usage typ
											exit 1
										esac
									if [[ $2 == "-"* ]] || [[ $2 == "" ]]; then
										break
									fi
									shift
								done
                                ;;
        -A | --anonymize )      ;;
		-R | --release )        shift
                                var_temp_arguments=${1^^}
                                case $var_temp_arguments in
									"FULL")
										var_release_full=true
										var_release_delta=false
										;;
									"DELTA")
										var_release_delta=true
										var_release_full=false
										;;
									* )
										usage backup
										exit 1
								esac
								;;
        -B | --backup )      	shift
                                var_temp_arguments=${1^^}
                                case $var_temp_arguments in
									"All")
										;;
									"VOLUMES")
										;;
									"SQL")
										;;
									"IMAGES")
										;;
									* )
										usage backup
										exit 1
								esac
								;;
        -h | --help )           usage help
                                exit
                                ;;
        * )                     usage general
                                exit 1
    esac
    shift
done

# create TEMP dir 
# TMP LIVE
sudo mkdir -p -- $var_temp_dir/LIVE/
sudo chown -R  $USER:$USER $var_temp_dir/LIVE/
sudo chmod -R 770 $var_temp_dir/LIVE/
# TMP NOTLIVE
sudo mkdir -p -- $var_temp_dir/NOTLIVE/
sudo chown -R $USER:$USER $var_temp_dir/NOTLIVE/
sudo chmod -R 770 $var_temp_dir/NOTLIVE/

# Prepare surrounding index.html
var_index_live=$(<$var_script_path/_templates/index.html)
var_index_notlive=$(<$var_script_path/_templates/index.html)

# Create Network
# create_docker_network

echo "setup Type" ${var_typ[@]} 
for var_typ_j in "${var_typ[@]}"
do
	export var_typ_j
	
	echo "Starting with type" $var_typ_j
	# Create Reverse Proxy & Prox Network for live and/or NOT live (all other typs then LIVE)
	if [[ $var_typ_j = "LIVE" ]]; then
		export var_live="true"
		export var_network_suffix="live"
		docker network create nginx-proxy-live
		docker-compose -p LIVE -f $var_script_path/_nginx-proxy-surrounding/LIVE/docker-compose.yml up -d --remove-orphans --force-recreate
	fi
	if 	[[ $var_typ_j = "REF"  	]] ||\
		[[ $var_typ_j = "STAGE" ]] ||\
		[[ $var_typ_j = "TEST"  ]] ||\
		[[ $var_typ_j = "DEV"  	]];\
		then
		export var_live="false"
		export var_network_suffix="notlive"
		docker network create nginx-proxy-notlive
		docker-compose -p NOTLIVE -f $var_script_path/_nginx-proxy-surrounding/NOTLIVE/docker-compose.yml up -d --remove-orphans --force-recreate
	fi
	
	for var_environment_i in "${var_environment[@]}"
	do
		export var_environment_i
		export var_http_port
		export var_server_name=$var_typ_j"_"$var_environment_i"."$var_base
		export var_project_name="project_"$var_server_name
		echo "Starting with type "$var_typ_j" and Environment "$var_environment_i
		
		# create enviornment files if not persent
		mkdir -p -- $var_script_path/$var_environment_i
		cp -n "$var_script_path/_jwilder_whoami/docker-compose.yml" "$var_script_path/$var_environment_i/docker-compose.yml"
		cp -n "$var_script_path/_jwilder_whoami/docker-compose.min.yml" "$var_script_path/$var_environment_i/docker-compose.$var_typ_j.yml"
		
		cp -n "$var_script_path/_templates/environment_bevorcomposeup.sh" "$var_script_path/$var_environment_i/environment_bevorcomposeup.sh"
		cp -n "$var_script_path/_templates/environment_bevorcomposeup.$var_typ_j.sh" "$var_script_path/$var_environment_i/environment_bevorcomposeup.$var_typ_j.sh"
		
		cp -n "$var_script_path/_templates/environment_aftercomposeup.sh" "$var_script_path/$var_environment_i/environment_aftercomposeup.sh"
		cp -n "$var_script_path/_templates/environment_aftercomposeup.$var_typ_j.sh" "$var_script_path/$var_environment_i/environment_aftercomposeup.$var_typ_j.sh"
		#sudo chmod +x "$var_script_path/$var_environment_i/*.sh"
		
		# execute individuall script bevor docker start
		echo "calling ..... $var_environment_i/environment_bevorcomposeup.sh"
		source "$var_script_path/$var_environment_i/environment_bevorcomposeup.sh"
		echo "calling ..... $var_environment_i/environment_bevorcomposeup.$var_typ_j.sh"
		source "$var_script_path/$var_environment_i/environment_bevorcomposeup.$var_typ_j.sh"
		# start docker 
		docker-compose \
						--project-name=$var_project_name\
						-f $var_script_path/$var_environment_i/docker-compose.yml \
						-f $var_script_path/$var_environment_i/docker-compose.$var_typ_j.yml \
						up -d --remove-orphans --force-recreate
		# execute individuall script after docker start
		echo "calling ..... $var_environment_i/environment_aftercomposeup.sh"
		source "$var_script_path/$var_environment_i/environment_aftercomposeup.sh"
		echo "calling ..... $var_environment_i/environment_aftercomposeup.$var_typ_j.sh"
		source "$var_script_path/$var_environment_i/environment_aftercomposeup.$var_typ_j.sh"

		#increment ports for new loop
		export var_http_port=$((var_http_port+30))
		export var_sql_port=$((var_sql_port+1))
		export var_smtp_port=$((var_smtp_port+1))
		export var_httpmail_port=$((var_smtp_port+1))
		
	done
done 
#finalize an copy index.html to surroundingserver
var_index_live="${var_index_live//PLACEHOLDER HEADER/Environment Type LIVE}"
var_index_notlive="${var_index_notlive//PLACEHOLDER HEADER/Environment Type NOT LIVE}"
#clean up placeholder
var_index_live="${var_index_live//PLACEHOLDER-MIDDLE8/}"
var_index_live="${var_index_live//PLACEHOLDER-LEFT2/}"
var_index_live="${var_index_live//PLACEHOLDER-RIGHT2/}"
var_index_notlive="${var_index_notlive//PLACEHOLDER-MIDDLE8/}"
var_index_notlive="${var_index_notlive//PLACEHOLDER-LEFT2/}"
var_index_notlive="${var_index_notlive//PLACEHOLDER-RIGHT2/}"

sudo echo $var_index_live > $var_temp_dir/LIVE/index.html
sudo echo $var_index_notlive > $var_temp_dir/NOTLIVE/index.html

docker cp $var_temp_dir/LIVE/index.html surrounding-live.vcap.me:/usr/share/nginx/html/index.html 
docker cp $var_temp_dir/NOTLIVE/index.html surrounding-notlive.vcap.me:/usr/share/nginx/html/index.html 

#docker ps | awk '{print $NF}'

: '
while [ condition ]
do
   statements1      #Executed as long as condition is true and/or, up to a disaster-condition if any.
   statements2
  if (disaster-condition)
  then
	break       	   #Abandon the while lopp.
  fi
  statements3          #While good and, no disaster-condition.
done

string="My long string"
if [[ $string == *"My long"* ]]; then
  echo "found!"
fi

# create docker volumes !! VOLUMES ONLY FOR LIVE AND DEV SYSTEM !!
if [ $typ_live ]; then
	if [ $var_steps_all | $var_steps_vol ]; then
		create_docker_volumes LIVE MARIADB
		create_docker_volumes LIVE MAILHOG
		create_docker_volumes LIVE PROXY
		create_docker_volumes LIVE GITINT
		create_docker_volumes LIVE GITEXT
		create_docker_volumes LIVE IMGINT
		create_docker_volumes LIVE IMGEXT
		#LIAM 2
		if [ $env_all | $env_liam2 ]; then
			create_docker_volumes LIVE LIAM2
		fi
		#LIAM 2 CLIENT
		if [ $env_all | $env_liam2_client ]; then
			create_docker_volumes LIVE LIAM2-CLIENT
		fi
		#SQMS 1
		if [ $env_all | $env_sqms ]; then
			create_docker_volumes LIVE SQMS
		fi
		#SQMS 1 CLIENT
		if [ $env_all | $env_sqms_client ]; then
			create_docker_volumes LIVE SQMS-CLIENT
		fi
		#SQMS 1 EXPORT
		if [ $env_all | $env_sqms_export ]; then
			create_docker_volumes LIVE SQMS-EXPORT
		fi
		#SQMS 2
		if [ $env_all | $env_sqms2 ]; then
			create_docker_volumes LIVE SQMS2
		fi
		#SQMS 2 CLIENT
		if [ $env_all | $env_sqms2_client ]; then
			create_docker_volumes LIVE SQMS2-CLIENT
		fi
		#COMS 1
		if [ $env_all | $env_coms ]; then
			create_docker_volumes LIVE COMS
		fi
		#COMS 1 CLIENT
		if [ $env_all | $env_coms_client ]; then
			create_docker_volumes LIVE COMS-CLIENT
		fi
		#COMS 2
		if [ $env_all | $env_coms2 ]; then
			create_docker_volumes LIVE COMS2
		fi
		#COMS 2 CLIENT
		if [ $env_all | $env_coms2_client ]; then
			create_docker_volumes LIVE COMS2-CLIENT
		fi
		
		#BWNGmitsm CLIENT
		if [ $env_all | $env_BWNGmitsm ]; then
			create_docker_volumes LIVE BWNGmitsm
		fi
		
		#WWW_BPMSPACE
		if [ $env_all | $env_www_bpm ]; then
			create_docker_volumes LIVE BWNGmitsm-WWW
		fi
		#WWW_ICO
		if [ $env_all | $env_www_ico ]; then
			create_docker_volumes LIVE ICO-WWW
		fi
		#WWW_MITSM
		if [ $env_all | $env_www_mitsm ]; then
			create_docker_volumes LIVE MITSM-WWWM
		fi
	fi
fi

git fetch --all && git reset --hard origin/master && chmod 700 setup_environment.sh  && ./setup_environment.sh && ./setup_environment.sh -E LIAM2_ICO && ./setup_environment.sh -E LIAM2_ICO -T LIVE && ./setup_environment.sh -E BASE LIAM2_ICO SQMS_ICO -T LIVE && ./setup_environment.sh -E BASE LIAM2_ICO SQMS_ICO -T LIVE REF && ./setup_environment.sh -E ALL -T ALL

docker stop  $(docker ps -a -q) && docker rm $(docker ps -a -q) &&  docker-compose -f /home/rob/bpmspace_docker/_nginx-proxy-surrounding/docker-compose.yml up -d

docker network -f prune 

docker  run -d --restart=always -p 127.0.0.1:23750:2375 -v /var/run/docker.sock:/var/run/docker.sock  alpine/socat  tcp-listen:2375,fork,reuseaddr unix-connect:/var/run/docker.sock

'
