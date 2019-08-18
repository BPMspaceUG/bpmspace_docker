#!/bin/bash
var_script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
var_temp_dir=/tmp/$(date +"%m_%d_%Y_%s")


test_docker_compose_yml="
version: "3"
services:
  base:
    image: hello-world
"
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

# default Value
var_steps_all=true
var_typ_all=true
var_enviroment=( "BASE" "LIAM2_ico" "LIAM2_CLIENT_ico" "SQMS_ico" "SQMS_CLIENT_ico" "SQMS_EXPORT_ico" "SQMS2_ico" "SQMS2_CLIENT_ico" "COMS_ico" "COMS_CLIENT_ico" "BWNG_mitsm" "WWW_bpmspace" "WWW_ico" "WWW_mitsm" "MOODLE_ico" )
var_typ=( "TEST" "DEV" )
var_release_full=true

while [ "$1" != "" ]; do
    case $1 in
        -S | --steps )     		shift
								var_temp_arguments=${1^^}
								var_steps_all=false
                                case $var_temp_arguments in
									ALL  )
										var_steps_all=true
										;;
									VOLUMES  )
										var_steps_vol=true
										;;
									COMPOSE  )
										var_steps_com=true
										;;
									RUN  )
										var_steps_run=true
										;;
									SQL  )
										var_steps_sql=true
										;;
									GIT  )
										var_steps_git=true
										;;
									* )
										usage steps
										exit 1
								esac
                                ;;
        -E | --enviroment )     shift
								var_enviroment=()
								while [ "$1" != "" ]
								do
									var_temp_arguments=${1^^}
									case $var_temp_arguments in
										"ALL"  )
											var_enviroment=(  "BASE" "LIAM2_ico" "LIAM2_CLIENT_ico" "SQMS_ico" "SQMS_CLIENT_ico" "SQMS_EXPORT_ico" "SQMS2_ico" "SQMS2_CLIENT_ico" "COMS" "COMS_CLIENT" "BWNG_mitsm" "WWW_bpmspace" "WWW_ico" "WWW_mitsm" "MOODLE_ico" )
											;;
										"BASE"   )
											var_enviroment+=( "BASE" )
											;;
										"LIAM2_ico"  )
											var_enviroment+=( "LIAM2_ico" )
											;;
										"LIAM2_CLIENT_ico"  )
											var_enviroment+=( "LIAM2_CLIENT_ico" )
											;;
										"SQMS_ico"  )
											var_enviroment+=( "SQMS_ico" )
											;;
										"SQMS_CLIENT_ico"  )
											var_enviroment+=( "SQMS_CLIENT_ico" )
											;;
										"SQMS_EXPORT_ico"  )
											var_enviroment+=( "SQMS_EXPORT_ico" )
											;;
										"SQMS2_ico"  )
											var_enviroment+=( "SQMS2_ico" )
											;;
										"SQMS2_CLIENT_ico"  )
											var_enviroment+=( "SQMS2_CLIENT_ico" )
											;;
										"COMS_ico" )
											var_enviroment+=( "COMS_ico" )
											;;
										"COMS_CLIENT_ico" )
											var_enviroment+=( "COMS_CLIENT_ico" )
											;;
										"BWNG_mitsm" )
											var_enviroment+=( "BWNG_mitsm" )
											;;
										"WWW_bpmspace" )
											var_enviroment+=( "WWW_bpmspace" )
											;;
										"WWW_ico" )
											var_enviroment+=( "WWW_ico" )
											;;
										"WWW_mitsm" )
											var_enviroment+=( "WWW_mitsm" )
											;;
										"MOODLE_ico" )
											var_enviroment+=( "MOODLE_ico" )
											;;
										* )
											usage enviroment
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
										ALL)
											var_typ=( "LIVE" "REF" "STAGE" "TEST" "DEV" )
											var_typ_all=true
											;;
										LIVE)
											var_typ+=( "LIVE")
											var_step_live=true
											;;
										REF)
											var_typ+=( "REF" )
											;;
										STAGE)
											var_typ+=( "STAGE" )
											;;
										TEST)
											var_typ+=( "TEST" )
											;;
										DEV)
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
									FULL)
										var_release_full=true
										var_release_delta=false
										;;
									DELTA)
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
									All)
										;;
									VOLUMES)
										;;
									SQL)
										;;
									IMAGES)
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


for var_typ_j in "${var_typ[@]}"
do
	for var_enviroment_i in "${var_enviroment[@]}"
	do
		echo $var_typ_j"_"$var_enviroment_i
		mkdir -p -- $var_script_path/$var_enviroment_i
		touch -a $var_script_path/$var_enviroment_i/docker-compose.yml
		echo "$test_docker_compose_yml" > "$var_script_path/$var_enviroment_i/docker-compose.yml"
		touch -a $var_script_path/$var_enviroment_i/docker-compose.$var_typ_j.yml
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
		if [ $env_all | $env_LIAM2_ico ]; then
			create_docker_volumes LIVE LIAM2_ico
		fi
		#LIAM 2 CLIENT
		if [ $env_all | $env_LIAM2_CLIENT_ico ]; then
			create_docker_volumes LIVE LIAM2_ico-CLIENT
		fi
		#SQMS_ico 1
		if [ $env_all | $env_SQMS_ico ]; then
			create_docker_volumes LIVE SQMS_ico
		fi
		#SQMS_ico 1 CLIENT
		if [ $env_all | $env_SQMS_CLIENT_ico ]; then
			create_docker_volumes LIVE SQMS_ico-CLIENT
		fi
		#SQMS_ico 1 EXPORT
		if [ $env_all | $env_SQMS_EXPORT_ico ]; then
			create_docker_volumes LIVE SQMS_ico-EXPORT
		fi
		#SQMS_ico 2
		if [ $env_all | $env_SQMS2_ico ]; then
			create_docker_volumes LIVE SQMS2_ico
		fi
		#SQMS_ico 2 CLIENT
		if [ $env_all | $env_SQMS2_CLIENT_ico ]; then
			create_docker_volumes LIVE SQMS2_ico-CLIENT
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
		
		#BWNG_mitsm CLIENT
		if [ $env_all | $env_BWNG_mitsm ]; then
			create_docker_volumes LIVE BWNG_mitsm
		fi
		
		#WWW_bpmspace
		if [ $env_all | $env_www_bpm ]; then
			create_docker_volumes LIVE BWNG_mitsm-WWW
		fi
		#WWW_ico
		if [ $env_all | $env_www_ico ]; then
			create_docker_volumes LIVE ICO-WWW
		fi
		#WWW_mitsm
		if [ $env_all | $env_www_mitsm ]; then
			create_docker_volumes LIVE MITSM-WWWM
		fi
	fi
fi
'
