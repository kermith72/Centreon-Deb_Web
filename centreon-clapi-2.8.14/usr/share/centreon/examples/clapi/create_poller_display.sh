#!/bin/bash
# create_poller_display.sh
# version 1.05
# date 14/10/2017
# use Centreon_Clapi
# $USER_CENTREON name of admin
# $PWD_CENTREON password admin
# $NAME_POLLER name of poller
# $PASSWORD_SQL passwd bdd poller
# version 1.02
# fix parameter negotiation
# fix parameter retention_path
# fix parameter stats
# version 1.03
# new parameter version 2.8.5
# version 1.04
# new parameter version 2.8.11
# add paramater daemon
# version 1.05
# add debug
# $DEBUG script debug

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} -u=<user centreon> -p=<passwd centreon> -n=<name poller> -b=<password bdd poller> [-d=[yes|no]]

This program create configuration poller display 

    -u|--user User Centreon.
    -p|--password Password Centreon.
    -n|--name Poller Name
    -b|--bddpoller Password bdd Poller
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
    -b=*|--bddpoller=*)
      PASSWORD_SQL="${i#*=}"
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
if [[ -z "$USER_CENTREON" ]] || [[ -z "$PWD_CENTREON" ]] || [[ -z "$NAME_POLLER" ]] || [[ -z "$PASSWORD_SQL" ]] ; then
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

#add Output IPv4 for poller module
[ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a listoutput -v $MIN_NAME_POLLER-module | grep -c $MIN_NAME_POLLER-module-output-display
RESULT=`$CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a listoutput -v $MIN_NAME_POLLER-module | grep -c $MIN_NAME_POLLER-module-output-display`
if [ $RESULT == 0 ]
then
    echo add Output IPv4 for poller module
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADDOUTPUT -v "$MIN_NAME_POLLER-module;$MIN_NAME_POLLER-module-output-display;ipv4"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADDOUTPUT -v "$MIN_NAME_POLLER-module;$MIN_NAME_POLLER-module-output-display;ipv4"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a listoutput -v $MIN_NAME_POLLER-module
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a listoutput -v $MIN_NAME_POLLER-module |
    while read line
    do
       NAME=$(echo $line | cut -d";" -f2 )
       ID=$(echo $line | cut -d";" -f1 )
       if [ "$MIN_NAME_POLLER-module-output-display" == "$NAME" ]
       then
         [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;$ID;protocol;bbdo"
         $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;$ID;protocol;bbdo"
         [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;$ID;tls;no"
         $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;$ID;tls;no"
         [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;$ID;compression;no"
         $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;$ID;compression;no"
         [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;$ID;port;5672"
         $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;$ID;port;5672"
         [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;$ID;retry_interval;"
         $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;$ID;retry_interval;"
         [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;$ID;buffering_timeout;"
         $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;$ID;buffering_timeout;"
         [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;$ID;host;localhost"
         $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;$ID;host;localhost"
        fi
    done
else
   echo output $MIN_NAME_POLLER-module-output-display for poller $MIN_NAME_POLLER-broker-display  already exist !
fi

#add centreon broker for poller
[ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a show -v $MIN_NAME_POLLER-broker-display | grep $MIN_NAME_POLLER-broker-display | cut -d";" -f2
RESULT=`$CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a show -v $MIN_NAME_POLLER-broker-display | grep $MIN_NAME_POLLER-broker-display | cut -d";" -f2`
if [ "$RESULT" != "$MIN_NAME_POLLER-broker-display" ]
then
    echo add centreon broker for poller
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADD -v "$MIN_NAME_POLLER-broker-display;$NAME_POLLER"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADD -v "$MIN_NAME_POLLER-broker-display;$NAME_POLLER"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-broker-display;filename;central-broker.xml"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-broker-display;filename;central-broker.xml"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-broker-display;cache_directory;/var/lib/centreon-broker"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-broker-display;cache_directory;/var/lib/centreon-broker"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-broker-display;stats_activate;1"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-broker-display;stats_activate;1"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-broker-display;daemon;1"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-broker-display;daemon;1"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-broker-display;write_timestamp;1"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-broker-display;write_timestamp;1"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-broker-display;write_thread_id;0"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-broker-display;write_thread_id;0"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADDLOGGER -v "$MIN_NAME_POLLER-broker-display;/var/log/centreon-broker/$MIN_NAME_POLLER-broker-display.log;file"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADDLOGGER -v "$MIN_NAME_POLLER-broker-display;/var/log/centreon-broker/$MIN_NAME_POLLER-broker-display.log;file"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-broker-display;1;config;yes"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-broker-display;1;config;yes"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-broker-display;1;debug;no"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-broker-display;1;debug;no"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-broker-display;1;error;yes"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-broker-display;1;error;yes"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-broker-display;1;info;no"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-broker-display;1;info;no"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-broker-display;1;level;low"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-broker-display;1;level;low"
    # INPUT IPv4
    [ "$DEBUG" == "yes" ] && echo  $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADDINPUT -v "$MIN_NAME_POLLER-broker-display;$MIN_NAME_POLLER-broker-display-input;ipv4"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADDINPUT -v "$MIN_NAME_POLLER-broker-display;$MIN_NAME_POLLER-broker-display-input;ipv4"
     [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setinput -v "$MIN_NAME_POLLER-broker-display;1;protocol;bbdo"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setinput -v "$MIN_NAME_POLLER-broker-display;1;protocol;bbdo"
     [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setinput -v "$MIN_NAME_POLLER-broker-display;1;tls;auto"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setinput -v "$MIN_NAME_POLLER-broker-display;1;tls;auto"
     [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setinput -v "$MIN_NAME_POLLER-broker-display;1;compression;auto"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setinput -v "$MIN_NAME_POLLER-broker-display;1;compression;auto"
     [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setinput -v "$MIN_NAME_POLLER-broker-display;1;negotiation;yes"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setinput -v "$MIN_NAME_POLLER-broker-display;1;negotiation;yes"
     [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setinput -v "$MIN_NAME_POLLER-broker-display;1;port;5672"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setinput -v "$MIN_NAME_POLLER-broker-display;1;port;5672"
    # OUTPUT Sql Centreon
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADDOUTPUT -v "$MIN_NAME_POLLER-broker-display;$MIN_NAME_POLLER-broker-display-mysql;sql"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADDOUTPUT -v "$MIN_NAME_POLLER-broker-display;$MIN_NAME_POLLER-broker-display-mysql;sql"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;1;db_type;mysql"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;1;db_type;mysql"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;1;db_host;localhost"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;1;db_host;localhost"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;1;db_port;3306"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;1;db_port;3306"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;1;db_user;centreon"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;1;db_user;centreon"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;1;db_password;$PASSWORD_SQL"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;1;db_password;$PASSWORD_SQL"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;1;db_name;centreon_storage"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;1;db_name;centreon_storage"
    # OUTPUT Perfdata Centreon
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADDOUTPUT -v "$MIN_NAME_POLLER-broker-display;$MIN_NAME_POLLER-broker-display-perfdata;storage"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADDOUTPUT -v "$MIN_NAME_POLLER-broker-display;$MIN_NAME_POLLER-broker-display-perfdata;storage"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;2;db_type;mysql"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;2;db_type;mysql"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;2;db_host;localhost"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;2;db_host;localhost"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;2;db_port;3306"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;2;db_port;3306"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;2;db_user;centreon"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;2;db_user;centreon"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;2;db_password;$PASSWORD_SQL"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;2;db_password;$PASSWORD_SQL"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;2;db_name;centreon_storage"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;2;db_name;centreon_storage"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;2;interval;60"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;2;interval;60"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;2;length;15552000"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;2;length;15552000"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;2;check_replication;no"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;2;check_replication;no"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;2;insert_in_index_data;yes"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;2;insert_in_index_data;yes"
    # OUTPUT RRD
    [ "$DEBUG" == "yes" ] && echo  $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADDOUTPUT -v "$MIN_NAME_POLLER-broker-display;$MIN_NAME_POLLER-broker-display-rrd;ipv4"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADDOUTPUT -v "$MIN_NAME_POLLER-broker-display;$MIN_NAME_POLLER-broker-display-rrd;ipv4"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;3;retry_interval;"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;3;retry_interval;"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;3;buffering_timeout;"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;3;buffering_timeout;"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;3;host;localhost"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;3;host;localhost"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;3;protocol;bbdo"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;3;protocol;bbdo"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;3;tls;auto"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;3;tls;auto"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;3;compression;auto"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;3;compression;auto"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;3;negotiation;yes"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;3;negotiation;yes"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;3;port;5670"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-broker-display;3;port;5670"
else
   echo module broker-display for poller $MIN_NAME_POLLER-broker-display  already exist !
fi

#add centreon rrd for poller
[ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a show -v $MIN_NAME_POLLER-rrd-display | grep $MIN_NAME_POLLER-rrd-display | cut -d";" -f2
RESULT=`$CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a show -v $MIN_NAME_POLLER-rrd-display | grep $MIN_NAME_POLLER-rrd-display | cut -d";" -f2`
if [ "$RESULT" != "$MIN_NAME_POLLER-rrd-display" ]
then
    echo add centreon rrd for poller
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADD -v "$MIN_NAME_POLLER-rrd-display;$NAME_POLLER"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADD -v "$MIN_NAME_POLLER-rrd-display;$NAME_POLLER"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-rrd-display;cache_directory;/var/lib/centreon-broker"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-rrd-display;cache_directory;/var/lib/centreon-broker"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-rrd-display;stats_activate;1"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-rrd-display;stats_activate;1"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-rrd-display;daemon;1"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-rrd-display;daemon;1"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-rrd-display;filename;central-rrd.xml"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-rrd-display;filename;central-rrd.xml"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-rrd-display;write_timestamp;1"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-rrd-display;write_timestamp;1"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-rrd-display;write_thread_id;0"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-rrd-display;write_thread_id;0"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADDLOGGER -v "$MIN_NAME_POLLER-rrd-display;/var/log/centreon-broker/$MIN_NAME_POLLER-rrd-display.log;file"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADDLOGGER -v "$MIN_NAME_POLLER-rrd-display;/var/log/centreon-broker/$MIN_NAME_POLLER-rrd-display.log;file"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-rrd-display;1;config;yes"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-rrd-display;1;config;yes"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-rrd-display;1;debug;no"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-rrd-display;1;debug;no"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-rrd-display;1;error;yes"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-rrd-display;1;error;yes"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-rrd-display;1;info;no"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-rrd-display;1;info;no"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-rrd-display;1;level;low"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-rrd-display;1;level;low"
    # INPUT IPv4
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADDINPUT -v "$MIN_NAME_POLLER-rrd-display;$MIN_NAME_POLLER-rrd-display-input;ipv4"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADDINPUT -v "$MIN_NAME_POLLER-rrd-display;$MIN_NAME_POLLER-rrd-display-input;ipv4"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setinput -v "$MIN_NAME_POLLER-rrd-display;1;protocol;bbdo"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setinput -v "$MIN_NAME_POLLER-rrd-display;1;protocol;bbdo"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setinput -v "$MIN_NAME_POLLER-rrd-display;1;tls;auto"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setinput -v "$MIN_NAME_POLLER-rrd-display;1;tls;auto"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setinput -v "$MIN_NAME_POLLER-rrd-display;1;compression;auto"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setinput -v "$MIN_NAME_POLLER-rrd-display;1;compression;auto"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setinput -v "$MIN_NAME_POLLER-rrd-display;1;negotiation;yes"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setinput -v "$MIN_NAME_POLLER-rrd-display;1;negotiation;yes"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setinput -v "$MIN_NAME_POLLER-rrd-display;1;port;5670"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setinput -v "$MIN_NAME_POLLER-rrd-display;1;port;5670"
    # OUTPUT RRD file
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADDOUTPUT -v "$MIN_NAME_POLLER-rrd-display;$MIN_NAME_POLLER-rrd-display-output;rrd"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a ADDOUTPUT -v "$MIN_NAME_POLLER-rrd-display;$MIN_NAME_POLLER-rrd-display-output;rrd"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-rrd-display;1;retry_interval;"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-rrd-display;1;retry_interval;"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-rrd-display;1;buffering_timeout;"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-rrd-display;1;buffering_timeout;"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-rrd-display;1;metrics_path;/var/lib/centreon/metrics"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-rrd-display;1;metrics_path;/var/lib/centreon/metrics"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-rrd-display;1;status_path;/var/lib/centreon/status"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-rrd-display;1;status_path;/var/lib/centreon/status"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-rrd-display;1;path;"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-rrd-display;1;path;"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-rrd-display;1;port;"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-rrd-display;1;port;"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-rrd-display;1;store_in_data_bin;no"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-rrd-display;1;store_in_data_bin;no"
    [ "$DEBUG" == "yes" ] && echo $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-rrd-display;1;write_status;yes"
    $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-rrd-display;1;write_status;yes"
else
   echo module broker-rrd for poller $NAME_POLLER-rrd-display  already exist !
fi
