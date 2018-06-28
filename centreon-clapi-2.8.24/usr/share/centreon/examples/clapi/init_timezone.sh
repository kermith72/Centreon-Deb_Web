#!/bin/bash
# init_timezone.sh
# version 1.01
# date 22/07/2016
# modify timezone php.ini
# $1 timezone
#
function usage(){
    echo Usage: $0 -t\|--timezone \<timezone\> -r\|--reload 1>&2
    echo This program modify /etc/php5/apache2/php.ini  1>&2
    echo for Centreon 1>&2
    exit 1
}

if [ $# -eq 0 ]
then
	usage
fi

OPTS=$( getopt -o hrt: -l reload,help,timezone: -- "$@" )

RELOAD=0

eval set -- "$OPTS"
while true ; do
    case "$1" in
        -h|--help) usage;
            exit 0;;
        -r|--reload) RELOAD=1;
                shift;;
        -t|--timezone) vartimezone=`echo $2 | sed 's:\/:\\\/:g' `;
                sed -i -e "s/;date.timezone =/date.timezone = $vartimezone/g" /etc/php5/apache2/php.ini;
                shift 2;;
        --) shift; break;;
    esac
done

if [ $RELOAD -eq 1 ]
then
  service apache2 reload
fi
