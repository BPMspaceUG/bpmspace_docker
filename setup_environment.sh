#!/bin/bash
var_script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
var_temp_dir=/tmp/$(date +"%m_%d_%Y_%s")


test_docker_compose_yml='
version: "3"
services:
  base:
    image: hello-world
'

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
}

# default Values
# nslookup to soemthing.vcap.me returns 127.0.0.1 
export var_base="vcap.me"
export var_http_proxport="8088"
export var_https_proxport="8044"
export var_http_port=10080
export var_https_port=10044
export var_steps_all=true
export var_typ_all=true
#var_environment=( "BASE" "LIAM2_ICO" "LIAM2_CLIENT_ICO" "SQMS_ICO" "SQMS_CLIENT_ICO" "SQMS_EXPORT" "SQMS2" "SQMS2_CLIENT" "COMS_ICO" "COMS_CLIENT_ICO" "BWNG_MITSM" "WWW_BPMSPACE" "WWW_ICO" "WWW_MITSM" "MOODLE_ICO" )
export var_environment=( "BASE" "LIAM2_ICO"  )
export var_typ=( "TEST" "DEV" )
export var_release_full=true
export var_release_delta=false

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
											var_environment=(  "BASE" "LIAM2_ICO" "LIAM2_CLIENT_ICO" "SQMS_ICO" "SQMS_CLIENT_ICO" "SQMS_EXPORT" "SQMS2" "SQMS2_CLIENT" "COMS_ICO" "COMS_CLIENT_ICO" "BWNG_MITSM" "WWW_BPMSPACE" "WWW_ICO" "WWW_MITSM" "MOODLE_ICO"  )
											;;
										"BASE"   )
											var_environment+=( "BASE" )
											;;
										"LIAM2_ICO"  )
											var_environment+=( "LIAM2_ICO" )
											;;
										"LIAM2_CLIENT_ICO"  )
											var_environment+=( "LIAM2_CLIENT_ICO" )
											;;
										"SQMS_ICO"  )
											var_environment+=( "SQMS_ICO" )
											;;
										"SQMS_CLIENT_ICO"  )
											var_environment+=( "SQMS_CLIENT_ICO" )
											;;
										"SQMS_EXPORT"  )
											var_environment+=( "SQMS_EXPORT" )
											;;
										"SQMS2"  )
											var_environment+=( "SQMS2" )
											;;
										"SQMS2_CLIENT"  )
											var_environment+=( "SQMS2_CLIENT" )
											;;
										"COMS_ICO" )
											var_environment+=( "COMS_ICO" )
											;;
										"COMS_CLIENT_ICO" )
											var_environment+=( "COMS_CLIENT_ICO" )
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

var_http_port=10080
create_docker_network
docker-compose -f $var_script_path/_jwilder_nginx-proxy/docker-compose.yml up -d

for var_typ_j in "${var_typ[@]}"
do
	for var_environment_i in "${var_environment[@]}"
	do
		export var_environment_i
		export var_typ_j
		export var_http_port
		export var_server_name=$var_typ_j"_"$var_environment_i"."$var_base
		export var_project_name="project_"$var_server_name
		echo $var_server_name
		mkdir -p -- $var_script_path/$var_environment_i
		#touch -a $var_script_path/$var_environment_i/docker-compose.yml
		rm $var_script_path/$var_environment_i/docker-compose.yml
		#touch -a $var_script_path/$var_environment_i/docker-compose.yml
		cp "$var_script_path/_helloworld/docker-compose.yml" "$var_script_path/$var_environment_i/docker-compose.yml"
		#touch -a $var_script_path/$var_environment_i/docker-compose.$var_typ_j.yml
		docker-compose \
						--project-name=$var_project_name\
						-f $var_script_path/$var_environment_i/docker-compose.yml \
		               up -d 
		               #-f $var_script_path/$var_environment_i/docker-compose.$var_typ_j.yml
		var_http_port=$((var_http_port+100))
		
	done
done 

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

docker stop  $(docker ps -a -q) && docker rm $(docker ps -a -q) &&  docker-compose -f /home/rob/bpmspace_docker/_jwilder_nginx-proxy/docker-compose.yml up -d

'
