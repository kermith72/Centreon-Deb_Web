#!/bin/bash
# create_template_snmp.sh
# version 1.00
# date 15/10/2017
# use Centreon_Clapi
# $USER_CENTREON name of admin
# $PWD_CENTREON password admin
# $DEBUG debug script clapi (optionnal)
# based on Hugues's script
## hugues@ruelle.fr


# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} -u=<user centreon> -p=<passwd centreon>  [-d=[yes|no]]

This program create configuration template snmp 

    -u|--user User Centreon.
    -p|--password Password Centreon.
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
if [[ -z "$USER_CENTREON" ]] || [[ -z "$PWD_CENTREON" ]] ; then
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

CLAPI="$CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON"

##################
#***** CMD  ******
##################
echo "Create Command"
# check_centreon_plugin_SNMP
[ "$DEBUG" == "yes" ] && echo $CLAPI -o CMD -a ADD -v 'check_centreon_plugin_SNMP;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=$_SERVICEPLUGIN$ --mode=$_SERVICEMODE$ --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ $_SERVICEOPTION$ --host=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$'
$CLAPI -o CMD -a ADD -v 'check_centreon_plugin_SNMP;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=$_SERVICEPLUGIN$ --mode=$_SERVICEMODE$ --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ $_SERVICEOPTION$ --host=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$'

#check_centreon_plugin_SNMP_traffic
[ "$DEBUG" == "yes" ] && echo $CLAPI -o CMD -a ADD -v 'check_centreon_plugin_SNMP_traffic;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=$_SERVICEPLUGIN$ --mode=$_SERVICEMODE$ --speed-in=$_SERVICESPEEDIN$ --speed-out=$_SERVICESPEEDOUT$ --interface=$_SERVICEINTERFACE$ --warning-in-traffic=$_SERVICEWARNINGIN$ --critical-in-traffic=$_SERVICECRITICALIN$ --warning-out-traffic=$_SERVICEWARNINGOUT$ --critical-out-traffic=$_SERVICECRITICALOUT$ $_SERVICEOPTION$ --host=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$'
$CLAPI -o CMD -a ADD -v 'check_centreon_plugin_SNMP_traffic;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=$_SERVICEPLUGIN$ --mode=$_SERVICEMODE$ --speed-in=$_SERVICESPEEDIN$ --speed-out=$_SERVICESPEEDOUT$ --interface=$_SERVICEINTERFACE$ --warning-in-traffic=$_SERVICEWARNINGIN$ --critical-in-traffic=$_SERVICECRITICALIN$ --warning-out-traffic=$_SERVICEWARNINGOUT$ --critical-out-traffic=$_SERVICECRITICALOUT$ $_SERVICEOPTION$ --host=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$'

#*****************

###############################
#***** SERVICES MODELES  ******
###############################
echo "Create template service"

# Traffics
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a add -v "Traffic-snmp-Model-Service;Traffic-snmp;service-generique-actif"
$CLAPI -o STPL -a add -v "Traffic-snmp-Model-Service;Traffic-snmp;service-generique-actif"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setparam -v "Traffic-snmp-Model-Service;check_command;check_centreon_plugin_SNMP_traffic"
$CLAPI -o STPL -a setparam -v "Traffic-snmp-Model-Service;check_command;check_centreon_plugin_SNMP_traffic"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Traffic-snmp-Model-Service;plugin;os::linux::snmp::plugin"
$CLAPI -o STPL -a setmacro -v "Traffic-snmp-Model-Service;plugin;os::linux::snmp::plugin"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Traffic-snmp-Model-Service;mode;interfaces"
$CLAPI -o STPL -a setmacro -v "Traffic-snmp-Model-Service;mode;interfaces"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Traffic-snmp-Model-Service;SPEEDIN;1000"
$CLAPI -o STPL -a setmacro -v "Traffic-snmp-Model-Service;SPEEDIN;1000"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Traffic-snmp-Model-Service;SPEEDOUT;1000"
$CLAPI -o STPL -a setmacro -v "Traffic-snmp-Model-Service;SPEEDOUT;1000"
[ "$DEBUG" == "yes" ] && echo $CLAPI  -o STPL -a setmacro -v "Traffic-snmp-Model-Service;INTERFACE;'eth0' --name"
$CLAPI -o STPL -a setmacro -v "Traffic-snmp-Model-Service;INTERFACE;'eth0' --name"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Traffic-snmp-Model-Service;option;--add-traffic --nagvis-perfdata"
$CLAPI -o STPL -a setmacro -v "Traffic-snmp-Model-Service;option;--add-traffic --nagvis-perfdata"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Traffic-snmp-Model-Service;WARNINGOUT;70"
$CLAPI -o STPL -a setmacro -v "Traffic-snmp-Model-Service;WARNINGOUT;70"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Traffic-snmp-Model-Service;CRITICALOUT;80"
$CLAPI -o STPL -a setmacro -v "Traffic-snmp-Model-Service;CRITICALOUT;80"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Traffic-snmp-Model-Service;WARNINGIN;75"
$CLAPI -o STPL -a setmacro -v "Traffic-snmp-Model-Service;WARNINGIN;75"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Traffic-snmp-Model-Service;CRITICALIN;85"
$CLAPI -o STPL -a setmacro -v "Traffic-snmp-Model-Service;CRITICALIN;85"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setparam -v "Traffic-snmp-Model-Service;graphtemplate;Traffic"
$CLAPI -o STPL -a setparam -v "Traffic-snmp-Model-Service;graphtemplate;Traffic"


#MODELE SERVICE SNMP
# CPU
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a add -v "Cpu-snmp-Model-Service;Cpu-snmp;service-generique-actif"
$CLAPI -o STPL -a add -v "Cpu-snmp-Model-Service;Cpu-snmp;service-generique-actif"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setparam -v "Cpu-snmp-Model-Service;check_command;check_centreon_plugin_SNMP"
$CLAPI -o STPL -a setparam -v "Cpu-snmp-Model-Service;check_command;check_centreon_plugin_SNMP"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Cpu-snmp-Model-Service;PLUGIN;os::linux::snmp::plugin"
$CLAPI -o STPL -a setmacro -v "Cpu-snmp-Model-Service;PLUGIN;os::linux::snmp::plugin"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Cpu-snmp-Model-Service;WARNING;70"
$CLAPI -o STPL -a setmacro -v "Cpu-snmp-Model-Service;WARNING;70"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Cpu-snmp-Model-Service;CRITICAL;90"
$CLAPI -o STPL -a setmacro -v "Cpu-snmp-Model-Service;CRITICAL;90"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Cpu-snmp-Model-Service;MODE;cpu"
$CLAPI -o STPL -a setmacro -v "Cpu-snmp-Model-Service;MODE;cpu"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setparam -v "Cpu-snmp-Model-Service;graphtemplate;CPU"
$CLAPI -o STPL -a setparam -v "Cpu-snmp-Model-Service;graphtemplate;CPU"


# DISK
# Model Disk
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a add -v "Disk-snmp-Model-Service;disk-snmp-model;service-generique-actif"
$CLAPI -o STPL -a add -v "Disk-snmp-Model-Service;disk-snmp-model;service-generique-actif"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setparam -v "Disk-snmp-Model-Service;check_command;check_centreon_plugin_SNMP"
$CLAPI -o STPL -a setparam -v "Disk-snmp-Model-Service;check_command;check_centreon_plugin_SNMP"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Disk-snmp-Model-Service;PLUGIN;os::linux::snmp::plugin"
$CLAPI -o STPL -a setmacro -v "Disk-snmp-Model-Service;PLUGIN;os::linux::snmp::plugin"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Disk-snmp-Model-Service;WARNING;80"
$CLAPI -o STPL -a setmacro -v "Disk-snmp-Model-Service;WARNING;80"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Disk-snmp-Model-Service;CRITICAL;90"
$CLAPI -o STPL -a setmacro -v "Disk-snmp-Model-Service;CRITICAL;90"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Disk-snmp-Model-Service;MODE;storage"
$CLAPI -o STPL -a setmacro -v "Disk-snmp-Model-Service;MODE;storage"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setparam -v "Disk-snmp-Model-Service;graphtemplate;Storage"
$CLAPI -o STPL -a setparam -v "Disk-snmp-Model-Service;graphtemplate;Storage"


# Disk home
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a add -v "Disk-snmp-home-Model-Service;Disk-snmp-Home;Disk-snmp-Model-Service"
$CLAPI -o STPL -a add -v "Disk-snmp-home-Model-Service;Disk-snmp-Home;Disk-snmp-Model-Service"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "disk-snmp-home-Model-Service;OPTION;--storage=/home --name"
$CLAPI -o STPL -a setmacro -v "disk-snmp-home-Model-Service;OPTION;--storage=/home --name"

# DISK
# Disk /
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a add -v "Disk-snmp-/-Model-Service;Disk-snmp-/;Disk-snmp-Model-Service"
$CLAPI -o STPL -a add -v "Disk-snmp-/-Model-Service;Disk-snmp-/;Disk-snmp-Model-Service"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "disk-snmp-/-Model-Service;OPTION;--storage=/ --name"
$CLAPI -o STPL -a setmacro -v "disk-snmp-/-Model-Service;OPTION;--storage=/ --name"

# DISK
# Disk tmp
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a add -v "Disk-snmp-tmp-Model-Service;Disk-snmp-Tmp;Disk-snmp-Model-Service"
$CLAPI -o STPL -a add -v "Disk-snmp-tmp-Model-Service;Disk-snmp-Tmp;Disk-snmp-Model-Service"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "disk-snmp-tmp-Model-Service;OPTION;--storage=/tmp --name"
$CLAPI -o STPL -a setmacro -v "disk-snmp-tmp-Model-Service;OPTION;--storage=/tmp --name"

# DISK_MODELE
# Disk usr
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a add -v "Disk-snmp-usr-Model-Service;Disk-snmp-Usr;Disk-snmp-Model-Service"
$CLAPI -o STPL -a add -v "Disk-snmp-usr-Model-Service;Disk-snmp-Usr;Disk-snmp-Model-Service"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "disk-snmp-usr-Model-Service;OPTION;--storage=/usr --name"
$CLAPI -o STPL -a setmacro -v "disk-snmp-usr-Model-Service;OPTION;--storage=/usr --name"

# DISK
# Disk var
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a add -v "Disk-snmp-var-Model-Service;Disk-snmp-Var;Disk-snmp-Model-Service"
$CLAPI -o STPL -a add -v "Disk-snmp-var-Model-Service;Disk-snmp-Var;Disk-snmp-Model-Service"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "disk-snmp-var-Model-Service;OPTION;--storage=/var --name"
$CLAPI -o STPL -a setmacro -v "disk-snmp-var-Model-Service;OPTION;--storage=/var --name"

# DISK
# Disk opt
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a add -v "Disk-snmp-opt-Model-Service;Disk-snmp-Opt;Disk-snmp-Model-Service"
$CLAPI -o STPL -a add -v "Disk-snmp-opt-Model-Service;Disk-snmp-Opt;Disk-snmp-Model-Service"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "disk-snmp-opt-Model-Service;OPTION;--storage=/opt --name"
$CLAPI -o STPL -a setmacro -v "disk-snmp-opt-Model-Service;OPTION;--storage=/opt --name"


# LOAD
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a add -v "Load-snmp-Model-Service;Load-snmp;service-generique-actif"
$CLAPI -o STPL -a add -v "Load-snmp-Model-Service;Load-snmp;service-generique-actif"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setparam -v "Load-snmp-Model-Service;check_command;check_centreon_plugin_SNMP"
$CLAPI -o STPL -a setparam -v "Load-snmp-Model-Service;check_command;check_centreon_plugin_SNMP"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Load-snmp-Model-Service;PLUGIN;os::linux::snmp::plugin"
$CLAPI -o STPL -a setmacro -v "Load-snmp-Model-Service;PLUGIN;os::linux::snmp::plugin"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Load-snmp-Model-Service;WARNING;4,3,2"
$CLAPI -o STPL -a setmacro -v "Load-snmp-Model-Service;WARNING;4,3,2"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Load-snmp-Model-Service;CRITICAL;6,5,4"
$CLAPI -o STPL -a setmacro -v "Load-snmp-Model-Service;CRITICAL;6,5,4"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Load-snmp-Model-Service;MODE;load"
$CLAPI -o STPL -a setmacro -v "Load-snmp-Model-Service;MODE;load"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setparam -v "Load-snmp-Model-Service;graphtemplate;LOAD_Average"
$CLAPI -o STPL -a setparam -v "Load-snmp-Model-Service;graphtemplate;LOAD_Average"


# MEMORY
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a add -v "Memory-snmp-Model-Service;Memory-snmp;service-generique-actif"
$CLAPI -o STPL -a add -v "Memory-snmp-Model-Service;Memory-snmp;service-generique-actif"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setparam -v "Memory-snmp-Model-Service;check_command;check_centreon_plugin_SNMP"
$CLAPI -o STPL -a setparam -v "Memory-snmp-Model-Service;check_command;check_centreon_plugin_SNMP"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Memory-snmp-Model-Service;PLUGIN;os::linux::snmp::plugin"
$CLAPI -o STPL -a setmacro -v "Memory-snmp-Model-Service;PLUGIN;os::linux::snmp::plugin"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Memory-snmp-Model-Service;WARNING;70"
$CLAPI -o STPL -a setmacro -v "Memory-snmp-Model-Service;WARNING;70"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Memory-snmp-Model-Service;CRITICAL;90"
$CLAPI -o STPL -a setmacro -v "Memory-snmp-Model-Service;CRITICAL;90"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Memory-snmp-Model-Service;MODE;memory"
$CLAPI -o STPL -a setmacro -v "Memory-snmp-Model-Service;MODE;memory"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setparam -v "Memory-snmp-Model-Service;graphtemplate;Memory"
$CLAPI -o STPL -a setparam -v "Memory-snmp-Model-Service;graphtemplate;Memory"

# SWAP
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a add -v "Swap-snmp-Model-Service;Swap-snmp;service-generique-actif"
$CLAPI -o STPL -a add -v "Swap-snmp-Model-Service;Swap-snmp;service-generique-actif"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setparam -v "Swap-snmp-Model-Service;check_command;check_centreon_plugin_SNMP"
$CLAPI -o STPL -a setparam -v "Swap-snmp-Model-Service;check_command;check_centreon_plugin_SNMP"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Swap-snmp-Model-Service;PLUGIN;os::linux::snmp::plugin"
$CLAPI -o STPL -a setmacro -v "Swap-snmp-Model-Service;PLUGIN;os::linux::snmp::plugin"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Swap-snmp-Model-Service;WARNING;80"
$CLAPI -o STPL -a setmacro -v "Swap-snmp-Model-Service;WARNING;80"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Swap-snmp-Model-Service;CRITICAL;90"
$CLAPI -o STPL -a setmacro -v "Swap-snmp-Model-Service;CRITICAL;90"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setmacro -v "Swap-snmp-Model-Service;MODE;swap"
$CLAPI -o STPL -a setmacro -v "Swap-snmp-Model-Service;MODE;swap"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a setparam -v "Swap-snmp-Model-Service;graphtemplate;Memory"
$CLAPI -o STPL -a setparam -v "Swap-snmp-Model-Service;graphtemplate;Memory"

################################
#*******HOTES MODELES **********
################################
echo "Create template host"
# HOSTS OS-Linux-SNMP2
[ "$DEBUG" == "yes" ] && echo $CLAPI -o HTPL -a add -v "OS-Linux-SNMPV2;OS-Linux-SNMPV2;;;;"
$CLAPI -o HTPL -a add -v "OS-Linux-SNMPV2;OS-Linux-SNMPV2;;;;"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o HTPL -a setparam -v "OS-Linux-SNMPV2;host_snmp_version;2c"
$CLAPI -o HTPL -a setparam -v "OS-Linux-SNMPV2;host_snmp_version;2c"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a addhost -v "Cpu-snmp-Model-Service;OS-Linux-SNMPV2"
$CLAPI -o STPL -a addhost -v "Cpu-snmp-Model-Service;OS-Linux-SNMPV2"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a addhost -v "Load-snmp-Model-Service;OS-Linux-SNMPV2"
$CLAPI -o STPL -a addhost -v "Load-snmp-Model-Service;OS-Linux-SNMPV2"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a addhost -v "Memory-snmp-Model-Service;OS-Linux-SNMPV2"
$CLAPI -o STPL -a addhost -v "Memory-snmp-Model-Service;OS-Linux-SNMPV2"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a addhost -v "Swap-snmp-Model-Service;OS-Linux-SNMPV2"
$CLAPI -o STPL -a addhost -v "Swap-snmp-Model-Service;OS-Linux-SNMPV2"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a addhost -v "Traffic-snmp-Model-Service;OS-Linux-SNMPV2"
$CLAPI -o STPL -a addhost -v "Traffic-snmp-Model-Service;OS-Linux-SNMPV2"

[ "$DEBUG" == "yes" ] && echo $CLAPI -o HTPL -a add -v "OS-Linux-storage-SNMPV2;OS-Linux-storage-SNMPV2;;;;"
$CLAPI -o HTPL -a add -v "OS-Linux-storage-SNMPV2;OS-Linux-storage-SNMPV2;;;;"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a addhost -v "disk-snmp-/-Model-Service;OS-Linux-storage-SNMPV2"
$CLAPI -o STPL -a addhost -v "disk-snmp-/-Model-Service;OS-Linux-storage-SNMPV2"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a addhost -v "disk-snmp-home-Model-Service;OS-Linux-storage-SNMPV2"
$CLAPI -o STPL -a addhost -v "disk-snmp-home-Model-Service;OS-Linux-storage-SNMPV2"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a addhost -v "disk-snmp-tmp-Model-Service;OS-Linux-storage-SNMPV2"
$CLAPI -o STPL -a addhost -v "disk-snmp-tmp-Model-Service;OS-Linux-storage-SNMPV2"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a addhost -v "disk-snmp-usr-Model-Service;OS-Linux-storage-SNMPV2"
$CLAPI -o STPL -a addhost -v "disk-snmp-usr-Model-Service;OS-Linux-storage-SNMPV2"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a addhost -v "disk-snmp-var-Model-Service;OS-Linux-storage-SNMPV2"
$CLAPI -o STPL -a addhost -v "disk-snmp-var-Model-Service;OS-Linux-storage-SNMPV2"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a addhost -v "disk-snmp-opt-Model-Service;OS-Linux-storage-SNMPV2"
$CLAPI -o STPL -a addhost -v "disk-snmp-opt-Model-Service;OS-Linux-storage-SNMPV2"


# HOSTS OS-Linux-SNMP3
[ "$DEBUG" == "yes" ] && echo $CLAPI -o HTPL -a add -v "OS-Linux-SNMPV3;OS-Linux-SNMPV3;;;;"
$CLAPI -o HTPL -a add -v "OS-Linux-SNMPV3;OS-Linux-SNMPV3;;;;"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o HTPL -a setmacro -v "OS-Linux-SNMPV3;OPTIONV3;--snmp-username=adminSNMV3 --authpassphrase=MDPV3 --privpassphrase=supervision --authprotocol=MD5 --privprotocol=DES;1"
$CLAPI -o HTPL -a setmacro -v "OS-Linux-SNMPV3;OPTIONV3;--snmp-username=adminSNMV3 --authpassphrase=MDPV3 --privpassphrase=supervision --authprotocol=MD5 --privprotocol=DES;1"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o HTPL -a setparam -v "OS-Linux-SNMPV3;host_snmp_version;3"
$CLAPI -o HTPL -a setparam -v "OS-Linux-SNMPV3;host_snmp_version;3"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a addhost -v "Cpu-snmp-Model-Service;OS-Linux-SNMPV3"
$CLAPI -o STPL -a addhost -v "Cpu-snmp-Model-Service;OS-Linux-SNMPV3"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a addhost -v "Load-snmp-Model-Service;OS-Linux-SNMPV3"
$CLAPI -o STPL -a addhost -v "Load-snmp-Model-Service;OS-Linux-SNMPV3"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a addhost -v "Memory-snmp-Model-Service;OS-Linux-SNMPV3"
$CLAPI -o STPL -a addhost -v "Memory-snmp-Model-Service;OS-Linux-SNMPV3"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a addhost -v "Swap-snmp-Model-Service;OS-Linux-SNMPV3"
$CLAPI -o STPL -a addhost -v "Swap-snmp-Model-Service;OS-Linux-SNMPV3"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a addhost -v "Traffic-snmp-Model-Service;OS-Linux-SNMPV3"
$CLAPI -o STPL -a addhost -v "Traffic-snmp-Model-Service;OS-Linux-SNMPV3"

[ "$DEBUG" == "yes" ] && echo $CLAPI -o HTPL -a add -v "OS-Linux-storage-SNMPV3;OS-Linux-storage-SNMPV3;;;;"
$CLAPI -o HTPL -a add -v "OS-Linux-storage-SNMPV3;OS-Linux-storage-SNMPV3;;;;"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o HTPL -a setmacro -v "OS-Linux-storage-SNMPV3;OPTIONV3;--snmp-username=adminSNMV3 --authpassphrase=MDPV3 --privpassphrase=supervision --authprotocol=MD5 --privprotocol=DES;1"
$CLAPI -o HTPL -a setmacro -v "OS-Linux-storage-SNMPV3;OPTIONV3;--snmp-username=adminSNMV3 --authpassphrase=MDPV3 --privpassphrase=supervision --authprotocol=MD5 --privprotocol=DES;1"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o HTPL -a setparam -v "OS-Linux-storage-SNMPV3;host_snmp_version;3"
$CLAPI -o HTPL -a setparam -v "OS-Linux-storage-SNMPV3;host_snmp_version;3"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a addhost -v "disk-snmp-home-Model-Service;OS-Linux-storage-SNMPV3"
$CLAPI -o STPL -a addhost -v "disk-snmp-home-Model-Service;OS-Linux-storage-SNMPV3"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a addhost -v "disk-snmp-/-Model-Service;OS-Linux-storage-SNMPV3"
$CLAPI -o STPL -a addhost -v "disk-snmp-/-Model-Service;OS-Linux-storage-SNMPV3"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a addhost -v "disk-snmp-tmp-Model-Service;OS-Linux-storage-SNMPV3"
$CLAPI -o STPL -a addhost -v "disk-snmp-tmp-Model-Service;OS-Linux-storage-SNMPV3"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a addhost -v "disk-snmp-usr-Model-Service;OS-Linux-storage-SNMPV3"
$CLAPI -o STPL -a addhost -v "disk-snmp-usr-Model-Service;OS-Linux-storage-SNMPV3"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a addhost -v "disk-snmp-var-Model-Service;OS-Linux-storage-SNMPV3"
$CLAPI -o STPL -a addhost -v "disk-snmp-var-Model-Service;OS-Linux-storage-SNMPV3"
[ "$DEBUG" == "yes" ] && echo $CLAPI -o STPL -a addhost -v "disk-snmp-opt-Model-Service;OS-Linux-storage-SNMPV3"
$CLAPI -o STPL -a addhost -v "disk-snmp-opt-Model-Service;OS-Linux-storage-SNMPV3"
