#!/bin/bash

if [ $# -gt 0 ]; then
    echo "Your command line contains $# arguments"
else
    echo "Your command line contains no arguments"
fi

usage() {
sleep 1
}

create_docker_volumes() {
	docker volume create --name $1-$2-data
	docker volume create --name $1-$2-config
	docker volume create --name $1-$2-backup
}

# default Value
steps_all=true
var_enviromenet=( "LIAM2" "LIAM2_CLIENT" "SQMS SQMS_CLIENT" "SQMS_EXPORT" "SQMS2" "SQMS2_CLIENT" "COMS _CLIENT" "BWNG" "WWWbpmspace" "WWWico" "WWWmitsm")




while [ "$1" != "" ]; do
    case $1 in
        -S | --steps )     		shift
								tempvar=${1^^}
								steps_all=false
                                case $tempvar in
									ALL  )
										steps_all=true
										;;
									VOLUMES  )
										steps_vol=true
										;;
									COMPOSE  )
										steps_com=true
										;;
									RUN  )
										steps_run=true
										;;
									SQL  )
										steps_sql=true
										;;
									GIT  )
										steps_git=true
										;;
									* )usage
										exit 1
								esac
                                ;;
        -E | --enviroment )     shift
								tempvar=${1^^}
								var_enviromenet=()
                                case $tempvar in
									ALL  )
										var_enviromenet=( "LIAM2" "LIAM2_CLIENT" "SQMS SQMS_CLIENT" "SQMS_EXPORT" "SQMS2" "SQMS2_CLIENT" "COMS _CLIENT" "BWNG" "WWWbpmspace" "WWWico" "WWWmitsm")
										;;
									LIAM2  )
										var_enviromenet+=( "LIAM2" )
										;;
									LIAM2_CLIENT  )
										var_enviromenet+=( "LIAM2_CLIENT" )
										;;
									SQMS  )
										var_enviromenet+=( "SQMS" )
										;;
									SQMS_CLIENT  )
										var_enviromenet+=( "SQMS_CLIENT" )
										;;
									SQMS_EXPORT  )
										var_enviromenet+=( "SQMS_EXPORT" )
										;;
									SQMS2  )
										var_enviromenet+=( "SQMS2" )
										;;
									SQMS2_CLIENT  )
										var_enviromenet+=( "SQMS2_CLIENT" )
										;;
									COMS )
										var_enviromenet+=( "COMS" )
										;;
									COMS_CLIENT )
										var_enviromenet+=( "COMS_CLIENT" )
										;;
									BWNG )
										var_enviromenet+=( "BWNG" )
										;;
									WWWbpmspace )
										var_enviromenet+=( "WWWbpmspace" )
										;;
									WWWico )
										var_enviromenet+=( "WWWico" )
										;;
									WWWmitsm )
										var_enviromenet+=( "WWWmitsm" )
										;;
									* )usage
										exit 1
								esac
                                ;;
        -T | --type )         	shift
                                tempvar=${1^^}
								typ_devtest=false
                                case $tempvar in
									LIVE)
										typ_live=true
										;;
									REF)
										typ_ref=true
										;;
									STAGE)
										typ_stage=true
										;;
									TEST)
										typ_test=true
										;;
									DEV)
										typ_dev=true
										;;
									DEVTEST)
										typ_test=true
										typ_dev=true
										;;
									* )usage
										exit 1
								esac
                                ;;
        -A | --anonymize )      ;;
        -B | --backup )      	shift
                                tempvar=${1^^}
                                case $tempvar in
									All)
										;;
									VOLUMES)
										;;
									SQL)
										;;
									IMAGES)
										;;
									* )usage
										exit 1
								esac
								;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done


for i in "${var_enviromenet[@]}"
do
	echo $i
done
: '
# create docker volumes !! VOLUMES ONLY FOR LIVE AND DEV SYSTEM !!
if [ $typ_live ]; then
	if [ $steps_all | $steps_vol ]; then
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
		
		#BWNG CLIENT
		if [ $env_all | $env_bwng ]; then
			create_docker_volumes LIVE BWNG
		fi
		
		#WWWbpmspace
		if [ $env_all | $env_www_bpm ]; then
			create_docker_volumes LIVE BWNG-WWW
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
