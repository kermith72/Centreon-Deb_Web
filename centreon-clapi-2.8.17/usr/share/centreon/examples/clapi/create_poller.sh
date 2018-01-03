#!/bin/bash
# create_poller.sh
# version 1.05
# date 14/10/2017
# use Centreon_Clapi
# $USER_CENTREON name of admin
# $PWD_CENTREON password admin
# $NAME_POLLER name of poller
# $IP_POLLER poller ip
# $IP_CENTRAL central ip
# version 1.0.2
# fix parameter retention_path
# fix parameter stats
# version 1.0.3
# add generate conf
# version 1.0.4
# replace nagioscfg for enginecfg
# delete DEBIAN 7
# version 1.0.5
# add debug
# $DEBUG script debug
# remove param type for broker

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} -u=<user centreon> -p=<passwd centreon> -n=<name poller> -c=<ip central> -l=<ip poller> [-d=[yes|no]]

This program create template poller

    -u|--user User Centreon.
    -p|--password Password Centreon.
    -n|--name Poller Name
    -c|--ipcentral Central IP
    -l|--ippoller Poller IP
    -d|--debug show debug (yes/no)
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
    -n=*|--name=*)
      NAME_POLLER="${i#*=}"
      shift # past argument=value
      ;;
    -c=*|--ipcentral=*)
      IP_CENTRAL="${i#*=}"
      shift # past argument=value
      ;;
    -l=*|--ippoller=*)
      IP_POLLER="${i#*=}"
      shift # past argument=value
      ;;
    -d=*|--debug=*)
      DEBUG="${i#*=}"
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
if [[ -z "$USER_CENTREON" ]] || [[ -z "$PWD_CENTREON" ]] || [[ -z "$NAME_POLLER" ]] || [[ -z "$IP_CENTRAL" ]] || [[ -z "$IP_POLLER" ]]; then
    echo "Missing parameters!"
    show_help
    exit 2
fi

if [[ -z "$DEBUG" ]]; then
    DEBUG="no"
fi

# Check yes/no
if [[ $DEBUG =~ ^[yY][eE][sS]|[yY]$ ]]; then
  DEBUG="yes"
else
  DEBUG="no"
fi

CLAPI_DIR=/usr/bin
MIN_NAME_POLLER="$(echo $NAME_POLLER | tr 'A-Z' 'a-z')"

# create instance poller
RESULT=`$CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a show -v $NAME_POLLER | grep $NAME_POLLER | cut -d";" -f2`
if [ "$RESULT" != "$NAME_POLLER" ]
then
    echo create instance poller
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a ADD -v "$NAME_POLLER;$IP_POLLER;22;CENGINE"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a ADD -v "$NAME_POLLER;$IP_POLLER;22;CENGINE"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;localhost;0"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;localhost;0"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;is_default;0"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;is_default;0"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;ns_activate;1"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;ns_activate;1"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;init_script;centengine"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;init_script;centengine"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;init_script_centreontrapd;centreontrapd"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;init_script_centreontrapd;centreontrapd"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;nagios_bin;/usr/sbin/centengine"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;nagios_bin;/usr/sbin/centengine"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;nagios_perfdata;/var/log/centreon-engine/service-perfdata"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;nagios_perfdata;/var/log/centreon-engine/service-perfdata"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;nagiostats_bin;/usr/sbin/centenginestats"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;nagiostats_bin;/usr/sbin/centenginestats"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;centreonbroker_logs_path;/var/log/centreon-broker/watchdog.log"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;centreonbroker_logs_path;/var/log/centreon-broker/watchdog.log"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;centreonbroker_cfg_path;/etc/centreon-broker"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;centreonbroker_cfg_path;/etc/centreon-broker"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;centreonbroker_module_path;/usr/share/centreon/lib/centreon-broker"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;centreonbroker_module_path;/usr/share/centreon/lib/centreon-broker"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;centreonconnector_path;/usr/lib/centreon-connector"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;centreonconnector_path;/usr/lib/centreon-connector"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;snmp_trapd_path_conf;/etc/snmp/centreon_traps/"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o INSTANCE -a setparam -v "$NAME_POLLER;snmp_trapd_path_conf;/etc/snmp/centreon_traps/"
else
   echo instance $NAME_POLLER  already exist !
fi


#create module broker for poller
RESULT=`$CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a show -v $MIN_NAME_POLLER-module | grep $MIN_NAME_POLLER-module | cut -d";" -f2`
if [ "$RESULT" != "$MIN_NAME_POLLER-module" ]
then
   echo create module broker for poller
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADD -v "$MIN_NAME_POLLER-module;$NAME_POLLER"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADD -v "$MIN_NAME_POLLER-module;$NAME_POLLER"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-module;filename;$MIN_NAME_POLLER-module.xml"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-module;filename;$MIN_NAME_POLLER-module.xml"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-module;cache_directory;/var/lib/centreon-broker"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-module;cache_directory;/var/lib/centreon-broker"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-module;stats_activate;1"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-module;stats_activate;1"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADDLOGGER -v "$MIN_NAME_POLLER-module;/var/log/centreon-engine/$MIN_NAME_POLLER-module.log;file"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADDLOGGER -v "$MIN_NAME_POLLER-module;/var/log/centreon-engine/$MIN_NAME_POLLER-module.log;file"
  [ "$DEBUG" == "yes" ] && echo  $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-module;1;config;yes"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-module;1;config;yes"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-module;1;debug;no"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-module;1;debug;no"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-module;1;info;no"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-module;1;info;no"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-module;1;level;low"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-module;1;level;low"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADDOUTPUT -v "$MIN_NAME_POLLER-module;$MIN_NAME_POLLER-module-output;ipv4"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADDOUTPUT -v "$MIN_NAME_POLLER-module;$MIN_NAME_POLLER-module-output;ipv4"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;protocol;bbdo"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;protocol;bbdo"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;tls;no"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;tls;no"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;compression;no"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;compression;no"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;port;5669"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;port;5669"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;retry_interval;"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;retry_interval;"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;buffering_timeout;"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;buffering_timeout;"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;host;$IP_CENTRAL"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;host;$IP_CENTRAL"
else
   echo module broker for poller $MIN_NAME_POLLER  already exist !
fi

#create engine poller
RESULT=`$CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a show -v $NAME_POLLER-cfg | grep $NAME_POLLER-cfg | cut -d";" -f2`
if [ "$RESULT" != "$NAME_POLLER-cfg" ]
then
   echo create engine poller
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a add -v "$NAME_POLLER-cfg;$NAME_POLLER;Poller Engine"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a add -v "$NAME_POLLER-cfg;$NAME_POLLER;Poller Engine"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a setparam -v "$NAME_POLLER-cfg;status_file;/var/log/centreon-engine/status.dat"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a setparam -v "$NAME_POLLER-cfg;status_file;/var/log/centreon-engine/status.dat"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a setparam -v "$NAME_POLLER-cfg;cfg_dir;/etc/centreon-engine"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a setparam -v "$NAME_POLLER-cfg;cfg_dir;/etc/centreon-engine"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a setparam -v "$NAME_POLLER-cfg;log_file;/var/log/centreon-engine/centengine.log"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a setparam -v "$NAME_POLLER-cfg;log_file;/var/log/centreon-engine/centengine.log"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a setparam -v "$NAME_POLLER-cfg;temp_file;/var/log/centreon-engine/centengine.tmp"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a setparam -v "$NAME_POLLER-cfg;temp_file;/var/log/centreon-engine/centengine.tmp"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a setparam -v "$NAME_POLLER-cfg;lock_file;/var/lock/subsys/centengine.lock"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a setparam -v "$NAME_POLLER-cfg;lock_file;/var/lock/subsys/centengine.lock"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a setparam -v "$NAME_POLLER-cfg;command_file;/var/lib/centreon-engine/rw/centengine.cmd"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a setparam -v "$NAME_POLLER-cfg;command_file;/var/lib/centreon-engine/rw/centengine.cmd"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a setparam -v "$NAME_POLLER-cfg;log_archive_path;/var/log/centreon-engine/archives/"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a setparam -v "$NAME_POLLER-cfg;log_archive_path;/var/log/centreon-engine/archives/"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a setparam -v "$NAME_POLLER-cfg;state_retention_file;/var/log/centreon-engine/retention.dat"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a setparam -v "$NAME_POLLER-cfg;state_retention_file;/var/log/centreon-engine/retention.dat"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a setparam -v "$NAME_POLLER-cfg;broker_module;/usr/lib/centreon-engine/externalcmd.so|/usr/lib/centreon-broker/cbmod.so /etc/centreon-broker/$MIN_NAME_POLLER-module.xml"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a setparam -v "$NAME_POLLER-cfg;broker_module;/usr/lib/centreon-engine/externalcmd.so|/usr/lib/centreon-broker/cbmod.so /etc/centreon-broker/$MIN_NAME_POLLER-module.xml"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a setparam -v "$NAME_POLLER-cfg;nagios_user;centreon-engine"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a setparam -v "$NAME_POLLER-cfg;nagios_user;centreon-engine"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a setparam -v "$NAME_POLLER-cfg;nagios_group;centreon-engine"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o enginecfg -a setparam -v "$NAME_POLLER-cfg;nagios_group;centreon-engine"
else
   echo engine poller $NAME_POLLER-cfg  already exist !
fi

#apply poller to resourcecfg
echo apply poller to resourcecfg
[ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o resourcecfg -a show
$CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o resourcecfg -a show |
while read line
do
   NAME=$(echo $line | cut -d";" -f2 )
   ID=$(echo $line | cut -d";" -f1 )
   CHAINE=$(echo $line | cut -d";" -f6 )
   if [ "\$USER1\$" == "$NAME" ]
   then
     CONCACT=$CHAINE\|$NAME_POLLER
     [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o resourcecfg -a setparam -v "$ID;instance;$CONCACT"
     $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o resourcecfg -a setparam -v "$ID;instance;$CONCACT"
   fi
   if [ "\$CENTREONPLUGINS\$" == "$NAME" ]
   then
     CONCACT=$CHAINE\|$NAME_POLLER
     [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o resourcecfg -a setparam -v "$ID;instance;$CONCACT"
     $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o resourcecfg -a setparam -v "$ID;instance;$CONCACT"
   fi
done

#create host Group
RESULT=`$CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o hg -a show -v $NAME_HG | grep Linux-Servers | cut -d";" -f2`
if [ "$RESULT" != "$NAME_POLLER" ]
then
  echo create Hostgroup Linux-Servers
  [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o hg -a add -v "Linux-Servers;Linux-Servers"
  $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o hg -a add -v "Linux-Servers;Linux-Servers"
fi

#create poller host
RESULT=`$CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o host -a show -v $NAME_POLLER | grep $NAME_POLLER | cut -d";" -f2`
if [ "$RESULT" != "$NAME_POLLER" ]
then
   echo create poller host
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o host -a add -v "$NAME_POLLER;poller $NAME_POLLER;$IP_POLLER;generic-host;$NAME_POLLER;Linux-Servers"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o host -a add -v "$NAME_POLLER;poller $NAME_POLLER;$IP_POLLER;generic-host;$NAME_POLLER;Linux-Servers"
   #$CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o host -a addtemplate -v "$NAME_POLLER;Servers-Linux"
   #[ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o host -a addtemplate -v "$NAME_POLLER;Servers-Linux"
   $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o host -a applytpl -v "$NAME_POLLER"
   [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o host -a applytpl -v "$NAME_POLLER"
else
   echo poller host $NAME_POLLER  already exist !
fi

# generate conf
[ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -a POLLERGENERATE -v "$NAME_POLLER"
RESULT=`$CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -a POLLERGENERATE -v "$NAME_POLLER"`

# control result
if [ $? -ne 0 ]
then

        echo "Erreur generation: "$RESULT
else

	# test monitoring
	RESULT=`$CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -a POLLERTEST -v "$NAME_POLLER"`
	if [ $? -ne 0 ]
	then

       		 echo "Erreur test: "$RESULT
	else

	        # move config
       		 RESULT=`$CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -a CFGMOVE -v "$NAME_POLLER"`
        	if [ $? -ne 0 ]
       		then

                	echo "Erreur Move config: "$RESULT
       		else

                	# reload config
                	RESULT=`$CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -a POLLERRESTART -v "$NAME_POLLER"`
                	if [ $? -ne 0 ]
                	then

                       		echo "Erreur reload config: "$RESULT
                	else
				echo "reload config OK"
			fi
		fi
	fi
fi
