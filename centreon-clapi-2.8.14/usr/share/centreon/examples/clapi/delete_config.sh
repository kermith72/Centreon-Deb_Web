#!/bin/bash
# delete_config.sh
#  version 1.01
# date 29/10/2015
# delete conf centreon (hosts, host groups, host templates, service templates, service categories, check commands, resources)

if [ $# -ne 2 ]
then
    echo Usage: $0 \<Centreon admin\> \<Centreon password\> 1>&2
    echo This program delete config Centreon  1>&2
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


#*****************************************************************
#*    Delete Host Groups
#*****************************************************************
$CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o HG -a show -v |
while read line
do
   ID_NAME=`echo $line | cut -d";" -f2 `
   if [ "$ID_NAME" != "name" ]
   then
    echo  "delete Host Group : "$ID_NAME
        $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o HG -a del -v "$ID_NAME"
   fi
done

#*****************************************************************
#*    Delete Hosts
#*****************************************************************
$CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o HOST -a show -v |
while read line
do
   ID_NAME=`echo $line | cut -d";" -f2 `
   if [ "$ID_NAME" != "name" ]
   then
    echo  "delete host : "$ID_NAME
        $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o HOST -a del -v "$ID_NAME"
   fi
done


#*****************************************************************
#*    Delete Hosts Templates
#*****************************************************************
$CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o HTPL -a show -v |
while read line
do
   ID_NAME=`echo $line | cut -d";" -f2 `
   if [ "$ID_NAME" != "name" ]
   then
    echo  "delete Host template  : "$ID_NAME
        $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o HTPL -a del -v "$ID_NAME"
   fi
done


#*****************************************************************
#*    Delete Services Templates
#*****************************************************************
$CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o STPL -a show -v |
while read line
do
   ID_NAME=`echo $line | cut -d";" -f2 `
   if [ "$ID_NAME" != "description" ]
   then
    echo  "delete Service Template : "$ID_NAME
        $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o STPL -a del -v "$ID_NAME"
   fi
done


#*****************************************************************
#*    Delete Services Categories
#*****************************************************************
$CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o SC -a show -v |
while read line
do
   ID_NAME=`echo $line | cut -d";" -f2 `
   if [ "$ID_NAME" != "name" ]
   then
    echo  "delete Service categories : "$ID_NAME
        $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o SC -a del -v "$ID_NAME"
   fi
done


#*****************************************************************
#*    Delete Checks Command
#*****************************************************************
$CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CMD -a show -v |
while read line
do
   ID_NAME=`echo $line | cut -d";" -f2 `
   ID_TYPE=`echo $line | cut -d";" -f3 `
   if [[ "$ID_NAME" != "name" && "$ID_TYPE" == "check" ]]
   then
    echo  "delete check command : "$ID_NAME
        $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o CMD -a del -v "$ID_NAME"
   fi
done


#*****************************************************************
#*    Delete Resource
#*****************************************************************
$CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o RESOURCECFG -a show -v "$NAME" |
while read line
do
  ID=`echo $line | cut -d";" -f1 `
  echo  "delete custom macro : "$ID
  $CLAPI_DIR/centreon -u $USER_CENTREON -p $PWD_CENTREON -o RESOURCECFG -a del -v "$ID"
done
