#!/bin/bash
# add_macro_plugin.sh
# version 1.00
# date 10/11/2016
# use Centreon_Clapi
# $1 name of admin
# $2 password admin

if [ $# -ne 2 ]
then
    echo Usage: $0 admin password 1>&2
    echo This program create macro \$CENTREONPLUGINS\$  1>&2
    echo for Centreon plugin 1>&2
    exit 1
fi

CLAPI_DIR=/usr/bin
USER_CENTREON=$1
PWD_CENTREON=$2

# create ressource macro
RESULT=`$CLAPI_DIR/centreon -u $1 -p $2 -o RESOURCECFG -a show -v | grep CENTREONPLUGINS | cut -d";" -f2`
if [ "$RESULT" != "\$CENTREONPLUGINS\$" ]
then
    echo create instance poller
    $CLAPI_DIR/centreon -u $1 -p $2 -o RESOURCECFG -a ADD -v '$CENTREONPLUGINS$;/usr/lib/centreon/plugins;Central;Centreon Plugins Path'
    RESULT=`$CLAPI_DIR/centreon -u $1 -p $2 -o RESOURCECFG -a show -v | grep CENTREONPLUGINS | cut -d";" -f1`
    $CLAPI_DIR/centreon -u $1 -p $2 -o RESOURCECFG -a setparam -v "$RESULT;activate;1"
else
   echo macro CENTREONPLUGIN  already exist !
fi
