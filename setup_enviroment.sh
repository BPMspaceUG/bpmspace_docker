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
var_enviroment=( "BASE" "LIAM2" "LIAM2_CLIENT" "SQMS SQMS_CLIENT" "SQMS_EXPORT" "SQMS2" "SQMS2_CLIENT" "COMS_CLIENT" "BWNGmitsm" "WWWbpmspace" "WWWico" "WWWmitsm" "MOODLEico" )
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
										ALL  )
											var_enviroment=( "BASE" "LIAM2" "LIAM2_CLIENT" "SQMS SQMS_CLIENT" "SQMS_EXPORT" "SQMS2" "SQMS2_CLIENT" "COMS_CLIENT" "BWNGmitsm" "WWWbpmspace" "WWWico" "WWWmitsm" "MOODLEico" )
											;;
										BASE   )
											var_enviroment+=( "BASE" )
											;;
										LIAM2  )
											var_enviroment+=( "LIAM2" )
											;;
										LIAM2_CLIENT  )
											var_enviroment+=( "LIAM2_CLIENT" )
											;;
										SQMS  )
											var_enviroment+=( "SQMS" )
											;;
										SQMS_CLIENT  )
											var_enviroment+=( "SQMS_CLIENT" )
											;;
										SQMS_EXPORT  )
											var_enviroment+=( "SQMS_EXPORT" )
											;;
										SQMS2  )
											var_enviroment+=( "SQMS2" )
											;;
										SQMS2_CLIENT  )
											var_enviroment+=( "SQMS2_CLIENT" )
											;;
										COMS )
											var_enviroment+=( "COMS" )
											;;
										COMS_CLIENT )
											var_enviroment+=( "COMS_CLIENT" )
											;;
										BWNGmitsm )
											var_enviroment+=( "BWNGmitsm" )
											;;
										WWWbpmspace )
											var_enviroment+=( "WWWbpmspace" )
											;;
										WWWico )
											var_enviroment+=( "WWWico" )
											;;
										WWWmitsm )
											var_enviroment+=( "WWWmitsm" )
											;;
										MOODLEico )
											var_enviroment+=( "MOODLEico" )
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
		echo $test_docker_compose_yml >> $var_script_path/$var_enviroment_i/docker-compose.yml
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
		
		#WWWbpmspace
		if [ $env_all | $env_www_bpm ]; then
			create_docker_volumes LIVE BWNGmitsm-WWW
		fi
		#WWWico
		if [ $env_all | $env_www_ico ]; then
			create_docker_volumes LIVE ICO-WWW
		fi
		#WWWmitsm
		if [ $env_all | $env_www_mitsm ]; then
			create_docker_volumes LIVE MITSM-WWWM
		fi
	fi
fi
'
