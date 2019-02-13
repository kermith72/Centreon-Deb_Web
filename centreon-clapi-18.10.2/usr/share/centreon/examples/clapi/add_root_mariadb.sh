#!/bin/bash
# init_timezone.sh
# version 1.00
# date 13/02/2019
# add root to log into mariadb
#
function usage(){
    echo Usage: $0 
    echo This program add root to log into mariadb  1>&2
    exit 1
}

function add_root(){
/usr/bin/mysql <<EOF
use mysql;
update user set plugin='' where user='root';
flush privileges;
EOF
	exit 1
}

case "$1" in
     -h|--help) usage;
          exit 0;;
     *) add_root;
          exit 0;;
esac
