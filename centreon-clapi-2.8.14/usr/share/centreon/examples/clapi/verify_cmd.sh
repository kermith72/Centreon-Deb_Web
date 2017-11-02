#!/bin/bash
# verify_cmd.sh
# version 1.02
# 02/12/2015
# verify commande for service
# $1 name of admin
# $2 password admin
# $3 host name
# $4 service name
# $5 view detail parameters
# version 1.0.1
# bug host_snmp_version for host
# version 1.0.2
# bug with space in name service template

if [ $# -lt 4 ]
then
    echo Usage: $0 admin password \<host name\> \<service name\> \<[-f\|--full] view detail\> 1>&2
    echo This program verify configuration service  1>&2
    echo and print command without macro and argument 1>&2
    exit 1
fi

VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"
ROSE="\\033[1;35m"
BLEU="\\033[1;34m"
BLANC="\\033[0;02m"
BLANCLAIR="\\033[1;08m"
JAUNE="\\033[1;33m"
CYAN="\\033[1;36m"

# Parameter
CLAPI_DIR=/usr/bin
USER_CENTREON=$1
PWD_CENTREON=$2
FILE_CONF=/tmp/export_host_clapi.txt
FILE_PARAM_CONF_STPL=/tmp/tempSTPL.parm
FILE_PARAM_CONF_HTPL=/tmp/tempHTPL.parm
FILE_PARAM_CONF_HOST=/tmp/tempHOST.parm
FILE_PARAM_CONF_SERVICE=/tmp/tempSERVICEparm
P_check_period=""
P_check_command=""
P_check_command_arguments=""
P_notification_period=""
P_service_is_volatile=0
P_service_max_check_attempts=0
P_service_normal_check_interval=0
P_service_retry_check_interval=0
P_service_active_checks_enabled=0
P_service_passive_checks_enabled=0
P_service_parallelize_check=0
P_service_obsess_over_service=0
P_service_check_freshness=0
P_service_event_handler_enabled=0
P_service_flap_detection_enabled=0
P_service_process_perf_data=0
P_service_retain_status_information=0
P_service_retain_nonstatus_information=0
P_service_notification_interval=0
P_service_notification_options=""
P_service_notifications_enabled=0
P_contact_additive_inheritance=0
P_cg_additive_inheritance=0
P_service_first_notification_delay=0
P_service_locked=0
P_service_register=0
P_service_activate=0
P_notes_url=""
declare -A ARRAY_MACRO
declare -A PILE
BP=100
SP=$BP
PILE_HTPL=
P_cmd=""
POLLER=""

H_hostaddress=""
H_check_command=""
H_notification_period=""
H_host_max_check_attempts=0
H_host_check_interval=0
H_host_retry_check_interval=0
H_host_active_checks_enabled=0
H_host_passive_checks_enabled=0
H_host_checks_enabled=0
H_host_obsess_over_host=0
H_host_check_freshness=0
H_host_event_handler_enabled=0
H_host_flap_detection_enabled=0
H_host_process_perf_data=0
H_host_retain_status_information=0
H_host_retain_nonstatus_information=0
H_host_notification_interval=0
H_host_notification_options=""
H_host_first_notification_delay=0
H_host_notifications_enabled=0
H_contact_additive_inheritance=0
H_cg_additive_inheritance=0
H_host_snmp_community=""
H_host_snmp_version=""
H_host_location=0
H_host_register=0
H_host_activate=0
H_notes_url=""

function insert_pile()
{
  if [ -z "$1" ]
  then
    return
  fi

  let "SP -= 1"
  PILE[$SP]=$1
  return
}

function retrieve_pile()
{
  PILE_HTPL=
  if [ "$SP" -eq "$BP" ]
  then
    return
  fi
  PILE_HTPL=${PILE[$SP]}
  let "SP += 1"
  return
}

function find_cmd ()
{
  local RESULT=$($CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o cmd -a export | grep -E -w "CMD;ADD;$1" | head -n 1 | cut -d ";" -f5)
  if [ -n "$RESULT" ]
  then
    P_cmd="$RESULT"
    return 0
  else
    echo "Critical : There is no service command !"
  fi


}

function read_htpl_param ()
{
  $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o htpl -a export | grep -E -w "$1" > $FILE_PARAM_CONF_HTPL

  #lecture param
  while read line
  do
    local PARAM1=`echo $line | cut -d";" -f1 `
    local PARAM2=`echo $line | cut -d";" -f2 `
    local PARAM3=`echo $line | cut -d";" -f3 `
    local PARAM4=`echo $line | cut -d";" -f4 `
    local PARAM5=`echo $line | cut -d";" -f5 `
    if [ "$PARAM2" == "setparam" ]
    then
      case "$PARAM4" in
        "check_command")H_check_command=$PARAM5;;
        "host_active_checks_enabled")H_host_active_checks_enabled=$PARAM5;;
        "notification_period")H_notification_period=$PARAM5;;
        "host_max_check_attempts")H_host_max_check_attempts=$PARAM5;;
        "host_check_interval")H_host_check_interval=$PARAM5;;
        "host_retry_check_interval")H_host_retry_check_interval=$PARAM5;;
        "host_passive_checks_enabled")H_host_passive_checks_enabled=$PARAM5;;
        "host_checks_enabled")H_host_checks_enabled=$PARAM5;;
        "host_obsess_over_host")H_host_obsess_over_host=$PARAM5;;
        "host_check_freshness")H_host_check_freshness=$PARAM5;;
        "host_event_handler_enabled")H_host_event_handler_enabled=$PARAM5;;
        "host_flap_detection_enabled")H_host_flap_detection_enabled=$PARAM5;;
        "host_process_perf_data")H_host_process_perf_data=$PARAM5;;
        "host_retain_status_information")H_host_retain_status_information=$PARAM5;;
        "host_retain_nonstatus_information")H_host_retain_nonstatus_information=$PARAM5;;
        "host_notification_interval")H_host_notification_interval=$PARAM5;;
        "host_notification_options")H_host_notification_options=$PARAM5;;
        "host_first_notification_delay")H_host_first_notification_delay=$PARAM5;;
        "host_notifications_enabled")H_host_notifications_enabled=$PARAM5;;
        "contact_additive_inheritance")H_contact_additive_inheritance=$PARAM5;;
        "cg_additive_inheritance")H_cg_additive_inheritance=$PARAM5;;
        "host_snmp_community")H_host_snmp_community=$PARAM5;;
        # if host_snmp_version = 0 apply template
        "host_snmp_version")if [ "$PARAM5" != "0" ]
                             then
                               H_host_snmp_version="$PARAM5"
                             fi
                             ;;
        "host_location")H_host_location=$PARAM5;;
        "host_register")H_host_register=$PARAM5;;
        "host_activate")H_host_activate=$PARAM5;;
        "notes_url")H_notes_url=$PARAM5;;
      esac
    fi
    if [ "$PARAM2" == "setmacro" ]
    then
      ARRAY_MACRO["_HOST${PARAM4}"]=$PARAM5
      #verif SNMP
      if [ "$PARAM4" == "snmpcommunity" ]
      then
        H_host_snmp_community=""
      fi
      if [ "$PARAM4" == "snmpversion" ]
      then
        H_host_snmp_version=""
      fi
    fi
  done < $FILE_PARAM_CONF_HTPL
}

function read_host_param ()
{
  $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o host -a export | grep -E -w "$1" > $FILE_PARAM_CONF_HOST

  #lecture poller
  while read line
  do
    local PARAM1=`echo $line | cut -d";" -f1 `
    local PARAM2=`echo $line | cut -d";" -f2 `
    local PARAM3=`echo $line | cut -d";" -f3 `
    local PARAM4=`echo $line | cut -d";" -f4 `
    local PARAM5=`echo $line | cut -d";" -f5 `
    local PARAM6=`echo $line | cut -d";" -f6 `
    local PARAM7=`echo $line | cut -d";" -f7 `
    if [ "$PARAM2" == "ADD" ]
    then
       POLLER=$PARAM7
    fi
  done < $FILE_PARAM_CONF_HOST


  #lecture htpl et ajout pile
  echo
  echo -e "$BLEU""Hosts templates"
  echo -e "###############" "$NORMAL"
  while read line
  do
    local PARAM1=`echo $line | cut -d";" -f1 `
    local PARAM2=`echo $line | cut -d";" -f2 `
    local PARAM3=`echo $line | cut -d";" -f3 `
    local PARAM4=`echo $line | cut -d";" -f4 `
    if [ "$PARAM2" == "addtemplate" ]
    then
       echo $PARAM4
       insert_pile "$PARAM4"
    fi
  done < $FILE_PARAM_CONF_HOST

  #lecture param htpl
  retrieve_pile
  while [ "$PILE_HTPL" != "" ]
  do
    read_htpl_param $PILE_HTPL
    retrieve_pile
  done

  #lecture param host er hostadress
  while read line
  do
    line=${line//\&quot;/\"}
    local PARAM1=`echo $line | cut -d";" -f1 `
    local PARAM2=`echo $line | cut -d";" -f2 `
    local PARAM3=`echo $line | cut -d";" -f3 `
    local PARAM4=`echo $line | cut -d";" -f4 `
    local PARAM5=`echo $line | cut -d";" -f5 `
    if [ "$PARAM2" == "ADD" ]
    then
      H_hostaddress=$PARAM5
    fi
    if [[ "$PARAM2" == "setparam" && "$PARAM3" == "$1" ]]
    then
      case "$PARAM4" in
        "check_command")H_check_command=$PARAM5;;
        "host_active_checks_enabled")H_host_active_checks_enabled=$PARAM5;;
        "notification_period")H_notification_period=$PARAM5;;
        "host_max_check_attempts")H_host_max_check_attempts=$PARAM5;;
        "host_check_interval")H_host_check_interval=$PARAM5;;
        "host_retry_check_interval")H_host_retry_check_interval=$PARAM5;;
        "host_passive_checks_enabled")H_host_passive_checks_enabled=$PARAM5;;
        "host_checks_enabled")H_host_checks_enabled=$PARAM5;;
        "host_obsess_over_host")H_host_obsess_over_host=$PARAM5;;
        "host_check_freshness")H_host_check_freshness=$PARAM5;;
        "host_event_handler_enabled")H_host_event_handler_enabled=$PARAM5;;
        "host_flap_detection_enabled")H_host_flap_detection_enabled=$PARAM5;;
        "host_process_perf_data")H_host_process_perf_data=$PARAM5;;
        "host_retain_status_information")H_host_retain_status_information=$PARAM5;;
        "host_retain_nonstatus_information")H_host_retain_nonstatus_information=$PARAM5;;
        "host_notification_interval")H_host_notification_interval=$PARAM5;;
        "host_notification_options")H_host_notification_options=$PARAM5;;
        "host_first_notification_delay")H_host_first_notification_delay=$PARAM5;;
        "host_notifications_enabled")H_host_notifications_enabled=$PARAM5;;
        "contact_additive_inheritance")H_contact_additive_inheritance=$PARAM5;;
        "cg_additive_inheritance")H_cg_additive_inheritance=$PARAM5;;
        "host_snmp_community")H_host_snmp_community=$PARAM5;;
        # if host_snmp_version = 0 apply template
        "host_snmp_version") if [ "$PARAM5" != "0" ]
                             then
                               H_host_snmp_version="$PARAM5"
                             fi
                             ;;
        "host_location")H_host_location=$PARAM5;;
        "host_register")H_host_register=$PARAM5;;
        "host_activate")H_host_activate=$PARAM5;;
        "notes_url")H_notes_url=$PARAM5;;
      esac
    fi
    if [ "$PARAM2" == "setmacro" ]
    then
      ARRAY_MACRO["_HOST${PARAM4}"]=$PARAM5
      #verif SNMP
      if [ "$PARAM4" == "snmpcommunity" ]
      then
        H_host_snmp_community=""
      fi
      if [ "$PARAM4" == "snmpversion" ]
      then
        H_host_snmp_version=""
      fi
    fi
  done < $FILE_PARAM_CONF_HOST

  return
}

function read_stpl_param ()
{
  $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o stpl -a export | grep -E -w "$1" > $FILE_PARAM_CONF_STPL
  while read line
  do
    line=${line//\&quot;/\"}
    local PARAM1=`echo $line | cut -d";" -f1 `
    local PARAM2=`echo $line | cut -d";" -f2 `
    local PARAM3=`echo $line | cut -d";" -f3 `
    local PARAM4=`echo $line | cut -d";" -f4 `
    local PARAM5=`echo $line | cut -d";" -f5 `
    if [[ "$PARAM2" == "setparam" && "$PARAM3" == "$1" ]]
    then
      case "$PARAM4" in
        "check_period")P_check_period=$PARAM5;;
        "check_command")P_check_command=$PARAM5;;
        "check_command_arguments")P_check_command_arguments==$PARAM5;;
        "notification_period")P_notification_period=$PARAM5;;
        "service_is_volatile")P_service_is_volatile=$PARAM5;;
        "service_max_check_attempts")P_service_max_check_attempts=$PARAM5;;
        "service_normal_check_interval")P_service_normal_check_interval=$PARAM5;;
        "service_retry_check_interval")P_service_retry_check_interval=$PARAM5;;
        "service_active_checks_enabled")P_service_active_checks_enabled=$PARAM5;;
        "service_passive_checks_enabled")P_service_passive_checks_enabled=$PARAM5;;
        "service_parallelize_check")P_service_parallelize_check=$PARAM5;;
        "service_obsess_over_service")P_service_obsess_over_service=$PARAM5;;
        "service_check_freshness")P_service_check_freshness=$PARAM5;;
        "service_event_handler_enabled")P_service_event_handler_enabled=$PARAM5;;
        "service_flap_detection_enabled")P_service_flap_detection_enabled=$PARAM5;;
        "service_process_perf_data")P_service_process_perf_data=$PARAM5;;
        "service_retain_status_information")P_service_retain_status_information=$PARAM5;;
        "service_retain_nonstatus_information")P_service_retain_nonstatus_information=$PARAM5;;
        "service_notification_interval")P_service_notification_interval=$PARAM5;;
        "service_notification_options")P_service_notification_options=$PARAM5;;
        "service_notifications_enabled")P_service_notifications_enabled=$PARAM5;;
        "contact_additive_inheritance")P_contact_additive_inheritance=$PARAM5;;
        "cg_additive_inheritance")P_cg_additive_inheritance=$PARAM5;;
        "service_first_notification_delay")P_service_first_notification_delay=$PARAM5;;
        "service_locked")P_service_locked=$PARAM5;;
        "service_register")P_service_register=$PARAM5;;
        "service_activate")P_service_activate=$PARAM5;;
        "notes_url")P_notes_url=$PARAM5;;
      esac
    fi
    if [ "$PARAM2" == "setmacro" ]
    then
      ARRAY_MACRO["_SERVICE${PARAM4}"]=$PARAM5
    fi
  done < $FILE_PARAM_CONF_STPL
  return
}

function read_service_param ()
{
  $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o service -a export | grep -E -w "$1" | grep -E -w "$2" > $FILE_PARAM_CONF_SERVICE

  while read line
  do
    line=${line//\&quot;/\"}
    local PARAM1=`echo $line | cut -d";" -f1 `
    local PARAM2=`echo $line | cut -d";" -f2 `
    local PARAM3=`echo $line | cut -d";" -f3 `
    local PARAM4=`echo $line | cut -d";" -f4 `
    local PARAM5=`echo $line | cut -d";" -f5 `
    local PARAM6=`echo $line | cut -d";" -f6 `
    if [[ "$PARAM2" == "setparam" && "$PARAM3" == "$2" ]]
    then
      case "$PARAM5" in
        "check_period")P_check_period=$PARAM6;;
        "check_command")P_check_command=$PARAM6;;
        "check_command_arguments")P_check_command_arguments==$PARAM6;;
        "notification_period")P_notification_period=$PARAM6;;
        "service_is_volatile")P_service_is_volatile=$PARAM6;;
        "service_max_check_attempts")P_service_max_check_attempts=$PARAM6;;
        "service_normal_check_interval")P_service_normal_check_interval=$PARAM6;;
        "service_retry_check_interval")P_service_retry_check_interval=$PARAM6;;
        "service_active_checks_enabled")P_service_active_checks_enabled=$PARAM6;;
        "service_passive_checks_enabled")P_service_passive_checks_enabled=$PARAM6;;
        "service_parallelize_check")P_service_parallelize_check=$PARAM6;;
        "service_obsess_over_service")P_service_obsess_over_service=$PARAM6;;
        "service_check_freshness")P_service_check_freshness=$PARAM6;;
        "service_event_handler_enabled")P_service_event_handler_enabled=$PARAM6;;
        "service_flap_detection_enabled")P_service_flap_detection_enabled=$PARAM6;;
        "service_process_perf_data")P_service_process_perf_data=$PARAM6;;
        "service_retain_status_information")P_service_retain_status_information=$PARAM6;;
        "service_retain_nonstatus_information")P_service_retain_nonstatus_information=$PARAM6;;
        "service_notification_interval")P_service_notification_interval=$PARAM6;;
        "service_notification_options")P_service_notification_options=$PARAM6;;
        "service_notifications_enabled")P_service_notifications_enabled=$PARAM6;;
        "contact_additive_inheritance")P_contact_additive_inheritance=$PARAM6;;
        "cg_additive_inheritance")P_cg_additive_inheritance=$PARAM6;;
        "service_first_notification_delay")P_service_first_notification_delay=$PARAM6;;
        "service_locked")P_service_locked=$PARAM6;;
        "service_register")P_service_register=$PARAM6;;
        "service_activate")P_service_activate=$PARAM6;;
        "notes_url")P_notes_url=$PARAM6;;
      esac
    fi
  done < $FILE_PARAM_CONF_SERVICE
  return
}


function read_stpl ()
{
  #echo function read_stpl
  local RESULT=$($CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o stpl -a export | grep -E -w "$1" | head -n 1 | cut -d ";" -f5)
  if [ -n "$RESULT" ]
  then
    echo $RESULT
    read_stpl "$RESULT"
  #else
  #  echo "il n'y a plus modele de service"
  fi
  read_stpl_param "$1"

  return
}

#######################################################################################
#
#
#
#######################################################################################

# READ service
RESULT=$($CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o service -a export | grep -E -w "$3" | grep -E -w "$4" | head -n 1 | cut -d ";" -f5)
if [ -n "$RESULT" ]
then
  echo -e "$BLEU""Services templates"
  echo -e "##################" "$NORMAL"
  echo $RESULT
  read_stpl "$RESULT"
else
  echo "there is no services templates"
fi
# READ host
read_host_param "$3"
if [[ $5 == "-f" || $5 == "--full" ]]
then
  echo
  echo -e "$BLEU""Read parameter host $3"
  echo -e "##################################" "$NORMAL"
  echo "check_command "$H_check_command
  echo "notification_period "$H_notification_period
  echo "host_max_check_attempts "$H_host_max_check_attempts
  echo "host_check_interval "$H_host_check_interval
  echo "host_retry_check_interval "$H_host_retry_check_interval
  echo "host_active_checks_enabled "$H_host_active_checks_enabled
  echo "host_passive_checks_enabled "$H_host_passive_checks_enabled
  echo "host_checks_enabled "$H_host_checks_enabled
  echo "host_obsess_over_host "$H_host_obsess_over_host
  echo "host_check_freshness "$H_host_check_freshness
  echo "host_event_handler_enabled "$H_host_event_handler_enabled
  echo "host_flap_detection_enabled "$H_host_flap_detection_enabled
  echo "host_process_perf_data "$H_host_process_perf_data
  echo "host_retain_status_information "$H_host_retain_status_information;
  echo "host_retain_nonstatus_information "$H_host_retain_nonstatus_information
  echo "host_notification_interval "$H_host_notification_interval
  echo "host_notification_options "$H_host_notification_options
  echo "host_first_notification_delay "$H_host_first_notification_delay
  echo "host_notifications_enabled "$H_host_notifications_enabled
  echo "contact_additive_inheritance "$H_contact_additive_inheritance
  echo "cg_additive_inheritance "$H_cg_additive_inheritance
  echo "host_snmp_community "$H_host_snmp_community
  echo "host_snmp_version "$H_host_snmp_version
  echo "host_register "$H_host_location
  echo "host_register "$H_host_register
  echo "host_activate "$H_host_activate
  echo "notes_url "$H_notes_url
fi
# READ parameter service
read_service_param "$3" "$4"
if [[ $5 == "-f" || $5 == "--full" ]]
then
  echo -e "$BLEU""lecture paramètre service $3 $4" "$NORMAL"
  echo "check_period "$P_check_period
  echo "check_command "$P_check_command
  echo "check_command_arguments "$P_check_command_arguments
  echo  "notification_period "$P_notification_period
  echo  "service_is_volatile "$P_service_is_volatile
  echo  "service_max_check_attempts "$P_service_max_check_attempts
  echo  "service_normal_check_interval "$P_service_normal_check_interval
  echo  "service_retry_check_interval "$P_service_retry_check_interval
  echo  "service_active_checks_enabled "$P_service_active_checks_enabled
  echo  "service_passive_checks_enabled "$P_service_passive_checks_enabled
  echo  "service_parallelize_check "$P_service_parallelize_check
  echo  "service_obsess_over_service "$P_service_obsess_over_service
  echo  "service_check_freshness "$P_service_check_freshness
  echo  "service_event_handler_enabled "$P_service_event_handler_enabled
  echo  "service_flap_detection_enabled "$P_service_flap_detection_enabled
  echo  "service_process_perf_data "$P_service_process_perf_data
  echo  "service_retain_status_information "$P_service_retain_status_information
  echo  "service_retain_nonstatus_information "$P_service_retain_nonstatus_information
  echo  "service_notification_interval "$P_service_notification_interval
  echo  "service_notification_options "$P_service_notification_options
  echo  "service_notifications_enabled "$P_service_notifications_enabled
  echo  "contact_additive_inheritance "$P_contact_additive_inheritance
  echo  "cg_additive_inheritance "$P_cg_additive_inheritance
  echo  "service_first_notification_delay "$P_service_first_notification_delay
  echo  "service_locked "$P_service_locked
  echo  "service_register"$P_service_register
  echo  "service_activate"$P_service_activate
  echo  "notes_url"$P_notes_url
fi
# find command for service
echo $P_check_command
find_cmd $P_check_command
P_cmd1=${P_cmd//\$/}
# verify parameter SNMP
if [ "$H_host_snmp_version" != "" ]
then
  P_cmd1=${P_cmd1/_HOSTSNMPVERSION/$H_host_snmp_version}
fi
if [ "$H_host_snmp_community" != "" ]
then
  P_cmd1=${P_cmd1/_HOSTSNMPCOMMUNITY/$H_host_snmp_community}
fi
# replace Macro
if [[ $5 == "-f" || $5 == "--full" ]]
then
  echo
  echo -e "$BLEU""Custom Macros"
  echo -e "#############" "$NORMAL"
fi
for elem in ${!ARRAY_MACRO[*]};
do
  if [[ $5 == "-f" || $5 == "--full" ]]
  then
    echo "Nom macro \"${elem}\" : "${ARRAY_MACRO[${elem}]}
  fi
  P_cmd1=${P_cmd1/$(echo $elem | tr 'a-z' 'A-Z')/${ARRAY_MACRO[${elem}]}}
done
# replace host address
if [ "$H_hostaddress" != "" ]
then
  P_cmd1=${P_cmd1/HOSTADDRESS/$H_hostaddress}
fi
# replace ARG if exist
if [ "$P_check_command_arguments" != "" ]
then
  if [[ $5 == "-f" || $5 == "--full" ]]
  then
    echo
    echo -e "$BLEU""Arguments"
    echo -e "#########" "$NORMAL"
  fi
  IFS='!' read -a array <<<"$P_check_command_arguments"
  for elem in ${!array[*]}
  do
    if [[ $5 == "-f" || $5 == "--full" ]]
    then
      if [ ${elem} != 0 ]
      then
        echo "ARG${elem} : "${array[${elem}]}
      fi
    fi
    P_cmd1=${P_cmd1/ARG${elem}/${array[${elem}]}}
  done
fi
# replace resourcecfg USER1
if [ $(expr match "$P_cmd1" "USER1") == 5 ]
then
  RESULT=$($CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o resourcecfg -a export | grep -E -w "USER1" | grep -E -w "$POLLER" | head -n 1 | cut -d ";" -f4)
  P_cmd1=${P_cmd1//USER1/$RESULT}
fi
# writing command
echo
echo -e "$BLEU""Command"
echo -e "-------------------" "$NORMAL"
echo $P_cmd
echo
echo -e "$BLEU""Command without macro and argument"
echo -e "----------------------------------" "$NORMAL"
echo $P_cmd1
