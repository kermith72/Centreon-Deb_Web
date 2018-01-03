#!/bin/bash
# create_trap.sh
# version 1.02
# date 06/10/2017
# use Centreon_Clapi
# USER_CENTREON name of admin
# PWD_CENTREON password admin
#
#
#
# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} -u=<user centreon> -p=<passwd centreon>

This program create template trap

    -u|--user User Centreon.
    -p|--password Password Centreon.
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
if [[ -z "$USER_CENTREON" ]] || [[ -z "$PWD_CENTREON" ]] ; then
    echo "Missing parameters!"
    show_help
    exit 2
fi

CLAPI_DIR=/usr/share/centreon/bin
CLAPI="${CLAPI_DIR}/centreon -u ${USER_CENTREON} -p ${PWD_CENTREON}"



##################
#***** CMD  ******
##################
echo "Create Command"
# check_HOST_ALIVE
RESULT=`$CLAPI -o CMD -a ADD -v 'check_centreon_dummy;2;$USER1$/check_centreon_dummy -s $ARG1$ -o $ARG2$ '`
if [ "$RESULT" == "Invalid credentials." ]
then
   echo "Invalid credential !!!!!"
   exit 0
fi


# create template generic service passif
RESULT=`$CLAPI -o STPL -a show -v generic-service-passif | grep generic-service-passif | cut -d";" -f2`
if [ "$RESULT" != "generic-service-passif" ]
then
   echo create template generic-service-passif
   $CLAPI -o STPL -a add -v "generic-service-passif;generic-service-passif;"
   $CLAPI -o STPL -a setparam -v "generic-service-passif;check_period;24x7"
   $CLAPI -o STPL -a setparam -v "generic-service-passif;check_command;check_centreon_dummy"
   $CLAPI -o STPL -a setparam -v 'generic-service-passif;check_command_arguments;!0!OK'
   $CLAPI -o STPL -a setparam -v "generic-service-passif;max_check_attempts;1"
   $CLAPI -o STPL -a setparam -v "generic-service-passif;normal_check_interval;1"
   $CLAPI -o STPL -a setparam -v "generic-service-passif;retry_check_interval;1"
   $CLAPI -o STPL -a setparam -v "generic-service-passif;active_checks_enabled;0"
   $CLAPI -o STPL -a setparam -v "generic-service-passif;passive_checks_enabled;1"
   $CLAPI -o STPL -a setparam -v "generic-service-passif;notifications_enabled;1"
   $CLAPI -o STPL -a addcontactgroup -v "generic-service-passif;Supervisors"
   $CLAPI -o STPL -a setparam -v "generic-service-passif;notification_interval;0"
   $CLAPI -o STPL -a setparam -v "generic-service-passif;notification_period;24x7"
   $CLAPI -o STPL -a setparam -v "generic-service-passif;notification_options;w,c,r,f,s"
   $CLAPI -o STPL -a setparam -v "generic-service-passif;first_notification_delay;0"
   $CLAPI -o STPL -a setparam -v "generic-service-passif;service_check_freshness;1"
   $CLAPI -o STPL -a setparam -v "generic-service-passif;service_freshness_threshold;300"
else
   echo template generic-service-passif already exist !
fi

# create template trap SNMP
RESULT=`$CLAPI -o STPL -a show -v Model_Trap_Linux | grep Model_Trap_Linux | cut -d";" -f2`
if [ "$RESULT" != "Model_Trap_Linux" ]
then
   echo create template trap SNMP
   $CLAPI -o STPL -a add -v "Model_Trap_Linux;TRAP_LINUX;generic-service-passif"
   $CLAPI -o STPL -a addhost -v "Model_Trap_Linux;OS-Linux-local" 
   $CLAPI -o STPL -a addtrap -v "Model_Trap_Linux;linkDown"
   $CLAPI -o STPL -a addtrap -v "Model_Trap_Linux;linkUp"
   $CLAPI -o STPL -a addtrap -v "Model_Trap_Linux;warmStart"
   $CLAPI -o STPL -a addtrap -v "Model_Trap_Linux;coldStart"
else
   echo template Model_Trap_Linux already exist !
fi

# apply submit result for generic traps
echo apply submit result
$CLAPI -o trap -a setparam -v "LinkDown;traps_submit_result_enable;1"
$CLAPI -o trap -a setparam -v "LinkUp;traps_submit_result_enable;1"
$CLAPI -o trap -a setparam -v "warmStart;traps_submit_result_enable;1"
$CLAPI -o trap -a setparam -v "coldStart;traps_submit_result_enable;1"

# generate trap database
if [ ! -d "/etc/snmp/centreon_traps/1" ]; then
     mkdir /etc/snmp/centreon_traps/1
     chown www-data:www-data /etc/snmp/centreon_traps/1
fi
/usr/share/centreon/bin/generateSqlLite 1 /etc/snmp/centreon_traps/1/centreontrapd.sdb
chown www-data:www-data /etc/snmp/centreon_traps/1/centreontrapd.sdb

# apply modele Trap for Central
$CLAPI -o host -a applytpl -v "Central"

# apply configuration
$CLAPI -a pollergenerate -v 1
$CLAPI -a cfgmove -v 1
$CLAPI -a pollerreload -v 1
