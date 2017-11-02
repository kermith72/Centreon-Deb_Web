#!/bin/bash
# create_config_initial_v1.sh
# version 1.00
# date 06/10/2017
# use API Clapi
# $USER_CENTREON name of admin
# $PWD_CENTREON password admin
# $USER_BDD name of user database Centreon
# $PWD_BDD password user database Centreon
# $ADD_STORAGE add storage /tmp /var /home
# based on Hugues's script
## hugues@ruelle.fr
## Centreon Configuration initial -> DEBIAN 8 -> CENTREON 2.8.12
## V 0.23 # 14/09/2017
## "Centreon-plugins_pl"
##"""""""""""""""""""""""""""""""""""""""""""""""""""""""#
##                                                       #
##   Commandes + Modeles Services + Modeles Hotes        #
##                                                       #
##   Hote : "Supervision"                                #
##   Service : Cpu                                       #
##			  Mem                            #
##			  Swap                           #
##			  Disk"/" 		         #
##			  Traffic "Eth0"                 #
##             Mysql                                     #
##      	- RESTE a faire : Services (apache2...)  #
##             Version Plugin Centreon  + MAJ            #
##         Logos et Liens Wiki des Modeles / Hotes       #
##                                                       #
##"""""""""""""""""""""""""""""""""""""""""""""""""""""""#

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} -u=<user centreon> -p=<passwd centreon> -d=<user database centreon> -w=<passwd database> -s=[yes|no]

This program create initial configuration

    -u|--user User Centreon.
    -p|--password Password Centreon.
    -d|--userdatabase User Database Centreon
    -w|--passworddatabase Password Database Centreon.
    -s|--storage Create Storage service (yes/no)
    -h|--help     help
EOF
}

for i in "$@"
do
  case $i in
    -u=*|--user=*)
      USER_CENTREON="${i#*=}"
      shift # past argument=value
      ;;
    -p=*|--password=*)
      PWD_CENTREON="${i#*=}"
      shift # past argument=value
      ;;
    -d=*|--userdatabase=*)
      USER_BDD="${i#*=}"
      shift # past argument=value
      ;;
    -w=*|--passworddatabase=*)
      PWD_BDD="${i#*=}"
      shift # past argument=value
      ;;
    -s=*|--storage=*)
      ADD_STORAGE="${i#*=}"
      shift # past argument=value
      ;;
    -h|--help)
      show_help
      exit 2
      ;;
    *)
            # unknown option
    ;;
  esac
done


# Check for missing parameters
if [[ -z "$USER_CENTREON" ]] || [[ -z "$PWD_CENTREON" ]] || [[ -z "$USER_BDD" ]] || [[ -z "$PWD_BDD" ]] || [[ -z "$ADD_STORAGE" ]]; then
    echo "Missing parameters!"
    show_help
    exit 2
fi

# Check yes/no
if [[ $ADD_STORAGE =~ ^[yY][eE][sS]|[yY]$ ]]; then
  ADD_STORAGE="yes"
else
  ADD_STORAGE="no"
fi

################################################################
#                       Parametres                             #
#                                                              #
#                                                              #
CLAPI_DIR=/usr/share/centreon/bin
CLAPI="${CLAPI_DIR}/centreon -u ${USER_CENTREON} -p ${PWD_CENTREON}"
#                                                              #
################################################################

##################
#***** CMD  ******
##################
echo "Create Command"
# check_HOST_ALIVE
RESULT=`$CLAPI -o CMD -a ADD -v 'check_host_alive;2;$USER1$/check_icmp -H $HOSTADDRESS$ -w 3000.0,80% -c 5000.0,100% -p 1 '`
if [ "$RESULT" == "Invalid credentials." ]
then
   echo "Invalid credential !!!!!"
   exit 0
fi

# check_ping
$CLAPI -o CMD -a ADD -v 'check_ping;check;$USER1$/check_icmp -H $HOSTADDRESS$ -n $_SERVICEPACKETNUMBER$ -w $_SERVICEWARNING$ -c $_SERVICECRITICAL$'


# check_centreon_plugin_local_os
$CLAPI -o CMD -a ADD -v 'check_centreon_plugin_local_os;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=$_SERVICEPLUGIN$ --mode=$_SERVICEMODE$ --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ $_SERVICEOPTION$ '

# check_centreon_plugin_disk_local_os
$CLAPI -o CMD -a ADD -v 'check_centreon_plugin_disk_local_os;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=$_SERVICEPLUGIN$ --mode=$_SERVICEMODE$ --warning-usage=$_SERVICEWARNING$ --critical-usage=$_SERVICECRITICAL$ $_SERVICEOPTION$ '

# check_centreon_plugin_network_os
$CLAPI -o CMD -a ADD -v 'check_centreon_plugin_local_networks_os;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=$_SERVICEPLUGIN$ --mode=$_SERVICEMODE$ --speed=$_SERVICESPEED$ --name=$_SERVICEINTERFACE$ --warning-out=$_SERVICEWARNING$ --critical-out=$_SERVICECRITICAL$ --warning-in=$_SERVICEWARNING$ --critical-in=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
 # WARNING IN ET OUT DE LA COMMANDE A REPRENDRE Dans le service template ... !!!!

#check_centreon_plugin_database
$CLAPI -o CMD -a ADD -v 'check_centreon_plugin_database;2;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=$_SERVICEPLUGIN$ --host=$HOSTADDRESS$ --mode=$_SERVICEMODE$ --username=$_SERVICEUSERNAME$ --password=$_SERVICEPASSWORD$  --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ $_SERVICEOPTION$ '

#*****************

###############################
#***** SERVICES MODELES  ******
###############################
echo "Create template service"
# service-generique-actif
$CLAPI -o STPL -a add -v "service-generique-actif;service-generique-actif;"
$CLAPI -o STPL -a setparam -v "service-generique-actif;check_period;24x7"
$CLAPI -o STPL -a setparam -v "service-generique-actif;max_check_attempts;3"
$CLAPI -o STPL -a setparam -v "service-generique-actif;normal_check_interval;5"
$CLAPI -o STPL -a setparam -v "service-generique-actif;retry_check_interval;2"
$CLAPI -o STPL -a setparam -v "service-generique-actif;active_checks_enabled;1"
$CLAPI -o STPL -a setparam -v "service-generique-actif;passive_checks_enabled;0"
$CLAPI -o STPL -a setparam -v "service-generique-actif;notifications_enabled;1"
$CLAPI -o STPL -a addcontactgroup -v "service-generique-actif;Supervisors"
$CLAPI -o STPL -a setparam -v "service-generique-actif;notification_interval;0"
$CLAPI -o STPL -a setparam -v "service-generique-actif;notification_period;24x7"
$CLAPI -o STPL -a setparam -v "service-generique-actif;notification_options;w,c,r,f,s"
$CLAPI -o STPL -a setparam -v "service-generique-actif;first_notification_delay;0"
echo "Create template service local"

## Ping Lan
#Ping-Lan-service
$CLAPI -o STPL -a add -v "Ping-Lan-service;Ping-Lan;service-generique-actif"
$CLAPI -o STPL -a setparam -v "Ping-Lan-service;check_command;check_ping"
$CLAPI -o STPL -a setmacro -v "Ping-Lan-service;PACKETNUMBER;5"
$CLAPI -o STPL -a setmacro -v "Ping-Lan-service;WARNING;220,20%"
$CLAPI -o STPL -a setmacro -v "Ping-Lan-service;CRITICAL;400,50%"
$CLAPI -o STPL -a setparam -v "Ping-Lan-service;graphtemplate;Latency"


## CPU
#Cpu-local-model-service
$CLAPI -o STPL -a add -v "Cpu-local-model-service;Cpu-local;service-generique-actif"
$CLAPI -o STPL -a setparam -v "Cpu-local-Model-Service;check_command;check_centreon_plugin_local_os"
$CLAPI -o STPL -a setmacro -v "Cpu-local-Model-Service;PLUGIN;os::linux::local::plugin"
$CLAPI -o STPL -a setmacro -v "Cpu-local-Model-Service;WARNING;70"
$CLAPI -o STPL -a setmacro -v "Cpu-local-Model-Service;CRITICAL;90"
$CLAPI -o STPL -a setmacro -v "Cpu-local-Model-Service;MODE;cpu"
$CLAPI -o STPL -a setparam -v "Cpu-local-Model-Service;graphtemplate;CPU"

## LOAD
#Load-local-Model-Service
$CLAPI -o STPL -a add -v "Load-local-Model-Service;Load-local;service-generique-actif"
$CLAPI -o STPL -a setparam -v "Load-local-Model-Service;check_command;check_centreon_plugin_local_os"
$CLAPI -o STPL -a setmacro -v "Load-local-Model-Service;PLUGIN;os::linux::local::plugin"
$CLAPI -o STPL -a setmacro -v "Load-local-Model-Service;WARNING;4,3,2"
$CLAPI -o STPL -a setmacro -v "Load-local-Model-Service;CRITICAL;6,5,4"
$CLAPI -o STPL -a setmacro -v "Load-local-Model-Service;MODE;load"
$CLAPI -o STPL -a setparam -v "Load-local-Model-Service;graphtemplate;LOAD_Average"

## MEMORY
#Memory-local-Model-Service
$CLAPI -o STPL -a add -v "Memory-local-Model-Service;Memory-local;service-generique-actif"
$CLAPI -o STPL -a setparam -v "Memory-local-Model-Service;check_command;check_centreon_plugin_local_os"
$CLAPI -o STPL -a setmacro -v "Memory-local-Model-Service;PLUGIN;os::linux::local::plugin"
$CLAPI -o STPL -a setmacro -v "Memory-local-Model-Service;WARNING;70"
$CLAPI -o STPL -a setmacro -v "Memory-local-Model-Service;CRITICAL;90"
$CLAPI -o STPL -a setmacro -v "Memory-local-Model-Service;MODE;memory"
$CLAPI -o STPL -a setparam -v "Memory-local-Model-Service;graphtemplate;Memory"

## SWAP
#Swap-local-Model-Service
$CLAPI -o STPL -a add -v "Swap-local-Model-Service;Swap-local;service-generique-actif"
$CLAPI -o STPL -a setparam -v "Swap-local-Model-Service;check_command;check_centreon_plugin_local_os"
$CLAPI -o STPL -a setmacro -v "Swap-local-Model-Service;PLUGIN;os::linux::local::plugin"
$CLAPI -o STPL -a setmacro -v "Swap-local-Model-Service;WARNING;80"
$CLAPI -o STPL -a setmacro -v "Swap-local-Model-Service;CRITICAL;90"
$CLAPI -o STPL -a setmacro -v "Swap-local-Model-Service;MODE;swap"
$CLAPI -o STPL -a setparam -v "Swap-local-Model-Service;graphtemplate;Memory"

echo "Create template service local disk"

## DISK
## Modele Disk
###disk-local-Model-Service
 $CLAPI -o STPL -a add -v "disk-local-Model-Service;disk-local-model;service-generique-actif"
 $CLAPI -o STPL -a setparam -v "disk-local-Model-Service;check_command;check_centreon_plugin_disk_local_os"
 $CLAPI -o STPL -a setmacro -v "disk-local-Model-Service;PLUGIN;os::linux::local::plugin"
 $CLAPI -o STPL -a setmacro -v "disk-local-Model-Service;WARNING;80"
 $CLAPI -o STPL -a setmacro -v "disk-local-Model-Service;CRITICAL;90"
 $CLAPI -o STPL -a setmacro -v "disk-local-Model-Service;MODE;storage"
 $CLAPI -o STPL -a setparam -v "disk-local-Model-Service;graphtemplate;Storage"
### Disk home
####disk-local-home-Model-Service
$CLAPI -o STPL -a add -v "disk-local-home-Model-Service;Disk-local-Home;disk-local-Model-Service"
$CLAPI -o STPL -a setmacro -v "disk-local-home-Model-Service;OPTION;--name /home"
#### Disk /
#disk-local-/-Model-Service
$CLAPI -o STPL -a add -v "disk-local-/-Model-Service;Disk-local-/;disk-local-Model-Service"
$CLAPI -o STPL -a setmacro -v "disk-local-/-Model-Service;OPTION;--name /"
#### Disk tmp
#disk-local-tmp-Model-Service
$CLAPI -o STPL -a add -v "disk-local-tmp-Model-Service;Disk-local-Tmp;disk-local-Model-Service"
$CLAPI -o STPL -a setmacro -v "disk-local-tmp-Model-Service;OPTION;--name /tmp"
#### Disk usr
#disk-local-usr-Model-Service
$CLAPI -o STPL -a add -v "disk-local-usr-Model-Service;Disk-local-Usr;disk-local-Model-Service"
$CLAPI -o STPL -a setmacro -v "disk-local-usr-Model-Service;OPTION;--name /usr"
#### Disk var
#disk-local-var-Model-Service
$CLAPI -o STPL -a add -v "disk-local-var-Model-Service;Disk-local-Var;disk-local-Model-Service"
$CLAPI -o STPL -a setmacro -v "disk-local-var-Model-Service;OPTION;--name /var"

echo "Create template service local traffic"

## TRAFFIC
# check_centreon_plugin_local_networks_os
$CLAPI -o STPL -a add -v "Traffic-local-Model-Service;Traffic-local;service-generique-actif"
$CLAPI -o STPL -a setparam -v "Traffic-local-Model-Service;check_command;check_centreon_plugin_local_networks_os"
$CLAPI -o STPL -a setmacro -v "Traffic-local-Model-Service;PLUGIN;os::linux::local::plugin"
$CLAPI -o STPL -a setmacro -v "Traffic-local-Model-Service;WARNINGOUT;70"
$CLAPI -o STPL -a setmacro -v "Traffic-local-Model-Service;CRITICALOUT;80"
$CLAPI -o STPL -a setmacro -v "Traffic-local-Model-Service;WARNINGIN;70"
$CLAPI -o STPL -a setmacro -v "Traffic-local-Model-Service;CRITICALIN;80"
$CLAPI -o STPL -a setmacro -v "Traffic-local-Model-Service;MODE;traffic"
$CLAPI -o STPL -a setmacro -v "Traffic-local-Model-Service;SPEED;1000"
$CLAPI -o STPL -a setmacro -v "Traffic-local-Model-Service;OPTION;--units=%"
$CLAPI -o STPL -a setmacro -v "Traffic-local-Model-Service;INTERFACE;eth0"
$CLAPI -o STPL -a setparam -v "Traffic-local-Model-Service;graphtemplate;Traffic"

#*****************

echo "Create template service local database"

## MySQL
## Modele_Srv_MySQL
$CLAPI -o STPL -a add -v "Modele_Srv_MySQL;Srv_MySQL;service-generique-actif"
$CLAPI -o STPL -a setparam -v "Modele_Srv_MySQL;check_command;check_centreon_plugin_database"
$CLAPI -o STPL -a setparam -v "Modele_Srv_MySQL;service_is_volatile;2"
$CLAPI -o STPL -a setparam -v "Modele_Srv_MySQL;service_active_checks_enabled;2"
$CLAPI -o STPL -a setparam -v "Modele_Srv_MySQL;service_passive_checks_enabled;2"
$CLAPI -o STPL -a setparam -v "Modele_Srv_MySQL;service_parallelize_check;2"
$CLAPI -o STPL -a setparam -v "Modele_Srv_MySQL;service_obsess_over_service;2"
$CLAPI -o STPL -a setparam -v "Modele_Srv_MySQL;service_check_freshness;2"
$CLAPI -o STPL -a setparam -v "Modele_Srv_MySQL;service_event_handler_enabled;2"
$CLAPI -o STPL -a setparam -v "Modele_Srv_MySQL;service_flap_detection_enabled;2"
$CLAPI -o STPL -a setparam -v "Modele_Srv_MySQL;service_process_perf_data;2"
$CLAPI -o STPL -a setparam -v "Modele_Srv_MySQL;service_retain_status_information;2"
$CLAPI -o STPL -a setparam -v "Modele_Srv_MySQL;service_retain_nonstatus_information;2"
$CLAPI -o STPL -a setparam -v "Modele_Srv_MySQL;service_notifications_enabled;2"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL;plugin;database::mysql::plugin"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL;username;${USER_BDD}"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL;password;${PWD_BDD}"

###MySQL_connection-time
$CLAPI -o STPL -a add -v "Modele_Srv_MySQL_connection-time;MySQL_connection-time;Modele_Srv_MySQL"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_connection-time;mode;connection-time"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_connection-time;warning;200"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_connection-time;critical;600"

###MySQL_qcache
$CLAPI -o STPL -a add -v "Modele_Srv_MySQL_qcache-hitrate;MySQL_qcache-hitrate;Modele_Srv_MySQL"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_qcache-hitrate;critical;10:"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_qcache-hitrate;mode;qcache-hitrate"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_qcache-hitrate;option;--lookback"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_qcache-hitrate;warning;30:"

###MySQL_queries
$CLAPI -o STPL -a add -v "Modele_Srv_MySQL_queries;MySQL_queries;Modele_Srv_MySQL"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_queries;warning;200"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_queries;critical;300"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_queries;mode;queries"

###MySQL_slow
$CLAPI -o STPL -a add -v "Modele_Srv_MySQL_slow-queries;MySQL_slow-queries;Modele_Srv_MySQL"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_slow-queries;mode;slow-queries"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_slow-queries;warning;0.1"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_slow-queries;critical;0.2"

###MySQL_threads
$CLAPI -o STPL -a add -v "Modele_Srv_MySQL_threads-connected;MySQL_threads-connected;Modele_Srv_MySQL"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_threads-connected;mode;threads-connected"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_threads-connected;warning;10"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_threads-connected;critical;20"

###MySQLdatabases
$CLAPI -o STPL -a add -v "Modele_Srv_MySQLdatabases-size;MySQL_connection-time;Modele_Srv_MySQL"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQLdatabases-size;mode;databases-size"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQLdatabases-size;warning;200"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQLdatabases-size;critical;600"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQLdatabases-size;filter;centreon"

###MySQLdatabases
$CLAPI -o STPL -a add -v "Modele_Srv_MySQLdatabases-size_detail;Srv_MySQLdatabases-size_detail;Modele_Srv_MySQL"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQLdatabases-size_detail;mode;databases-size"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQLdatabases-size_detail;warning;200"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQLdatabases-size_detail;critical;600"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQLdatabases-size_detail;filter;centreon"

###MySQL_open-files
$CLAPI -o STPL -a add -v "Modele_Srv_MySQL_open-files;MySQL_open-files;Modele_Srv_MySQL"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_open-files;mode;open-files"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_open-files;warning;60"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_open-files;critical;100"

###MySQL_long-queries
$CLAPI -o STPL -a add -v "Modele_Srv_MySQL_long-queries;MySQL_long-queries;Modele_Srv_MySQL"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_long-queries;mode;long-queries"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_long-queries;warning;0.1"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_long-queries;critical;0.2"

###MySQL_uptime
$CLAPI -o STPL -a add -v "Modele_Srv_MySQL_uptime;MySQL_uptime;Modele_Srv_MySQL"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_uptime;mode;uptime"
#*********************** Warning 6 mois=15778800 Sec   Critical 1 ans=31557600 Sec *******************************
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_uptime;warning;15778800"
$CLAPI -o STPL -a setmacro -v "Modele_Srv_MySQL_uptime;critical;31557600"


################################
#*******HOTES MODELES **********
################################
echo "Create template host"
#generic-host
$CLAPI -o HTPL -a ADD -v "generic-host;generic-host;;;;"
$CLAPI -o HTPL -a setparam -v "generic-host;check_command;check_host_alive"
$CLAPI -o HTPL -a setparam -v "generic-host;check_period;24x7"
$CLAPI -o HTPL -a setparam -v "generic-host;notification_period;24x7"
$CLAPI -o HTPL -a setparam -v "generic-host;host_max_check_attempts;5"
$CLAPI -o HTPL -a setparam -v "generic-host;host_active_checks_enabled;1"
$CLAPI -o HTPL -a setparam -v "generic-host;host_passive_checks_enabled;0"
$CLAPI -o HTPL -a setparam -v "generic-host;host_checks_enabled;2"
$CLAPI -o HTPL -a setparam -v "generic-host;host_obsess_over_host;2"
$CLAPI -o HTPL -a setparam -v "generic-host;host_check_freshness;2"
$CLAPI -o HTPL -a setparam -v "generic-host;host_event_handler_enabled;2"
$CLAPI -o HTPL -a setparam -v "generic-host;host_flap_detection_enabled;2"
$CLAPI -o HTPL -a setparam -v "generic-host;host_process_perf_data;2"
$CLAPI -o HTPL -a setparam -v "generic-host;host_retain_status_information;2"
$CLAPI -o HTPL -a setparam -v "generic-host;host_retain_nonstatus_information;2"
$CLAPI -o HTPL -a setparam -v "generic-host;host_notification_interval;0"
$CLAPI -o HTPL -a setparam -v "generic-host;host_notification_options;d,r"
$CLAPI -o HTPL -a setparam -v "generic-host;host_notifications_enabled;0"
$CLAPI -o HTPL -a setparam -v "generic-host;contact_additive_inheritance;0"
$CLAPI -o HTPL -a setparam -v "generic-host;cg_additive_inheritance;0"
$CLAPI -o HTPL -a setparam -v "generic-host;host_snmp_community;public"
$CLAPI -o HTPL -a setparam -v "generic-host;host_snmp_version;2c"
$CLAPI -o STPL -a addhost -v "Ping-Lan-service;generic-host"


##OS-Linux-local
$CLAPI -o HTPL -a add -v "OS-Linux-local;TPL_OS-Linux-local;;;;"
$CLAPI -o STPL -a addhost -v "Cpu-local-Model-Service;OS-Linux-local"
$CLAPI -o STPL -a addhost -v "disk-local-/-Model-Service;OS-Linux-local"
$CLAPI -o STPL -a addhost -v "Load-local-Model-Service;OS-Linux-local"
$CLAPI -o STPL -a addhost -v "Memory-local-Model-Service;OS-Linux-local"
$CLAPI -o STPL -a addhost -v "Swap-local-Model-Service;OS-Linux-local"
$CLAPI -o STPL -a addhost -v "Traffic-local-Model-Service;OS-Linux-local"

##OS-Linux-local-storage
$CLAPI -o HTPL -a add -v "OS-Linux-local-storage;TPL_OS-Linux-local-storage;;;;"
$CLAPI -o STPL -a addhost -v "disk-local-home-Model-Service;OS-Linux-local-storage"
$CLAPI -o STPL -a addhost -v "disk-local-tmp-Model-Service;OS-Linux-local-storage"
$CLAPI -o STPL -a addhost -v "disk-local-var-Model-Service;OS-Linux-local-storage"
$CLAPI -o STPL -a addhost -v "disk-local-usr-Model-Service;OS-Linux-local-storage"


##MySQL-Serveur
$CLAPI -o HTPL -a add -v "MySQL-Serveur;TPL_MySQL-Serveur-local;;;;"
$CLAPI -o STPL -a addhost -v "Modele_Srv_MySQL_connection-time;MySQL-Serveur"
$CLAPI -o STPL -a addhost -v "Modele_Srv_MySQL_qcache-hitrate;MySQL-Serveur"
$CLAPI -o STPL -a addhost -v "Modele_Srv_MySQL_queries;MySQL-Serveur"
$CLAPI -o STPL -a addhost -v "Modele_Srv_MySQL_slow-queries;MySQL-Serveur"
$CLAPI -o STPL -a addhost -v "Modele_Srv_MySQL_threads-connected;MySQL-Serveur"
$CLAPI -o STPL -a addhost -v "Modele_Srv_MySQLdatabases-size;MySQL-Serveur"
$CLAPI -o STPL -a addhost -v "Modele_Srv_MySQL_open-files;MySQL-Serveur"
$CLAPI -o STPL -a addhost -v "Modele_Srv_MySQL_long-queries;MySQL-Serveur"
$CLAPI -o STPL -a addhost -v "Modele_Srv_MySQL_uptime;MySQL-Serveur"



################################################################
#               Creation hote Supervision                      #
################################################################
echo "Create Central"
$CLAPI -o host -a add -v "Central;Monitoring Server;127.0.0.1;;central;"
$CLAPI -o host -a addtemplate -v "Central;generic-host"
$CLAPI -o host -a addtemplate -v "Central;os-linux-local"
if [ "$ADD_STORAGE" == "yes" ]
then
  echo "add storage"
  $CLAPI -o host -a addtemplate -v "Central;os-linux-local-storage"
fi
$CLAPI -o host -a addtemplate -v "Central;MySQL-Serveur"
# application des modeles a l hote
$CLAPI -o host -a applytpl -v "Central"

   ### application de la configation poller "central"

   #*****************

RESULT=`$CLAPI -a pollertest -v 1`
if [ $? = 0 ];then
   $CLAPI -a pollergenerate -v 1
   $CLAPI -a cfgmove -v 1
   RESULT=`$CLAPI -a pollerreload -v 1`
   if [ $? = 0 ];then
     echo "Configuration OK !"
   else
     echo "Error Configuration !!!"
   fi
else
  echo "Error configuration !!!"
fi
