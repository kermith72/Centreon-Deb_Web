#!/bin/bash
# change_rights.sh
# change right for log file in /var/log/centreon
# version 1
# Date 27/04/2016
# Eric Coquard

if [[ "`ls -A /var/log/centreon`" ]]
then
  chmod 664 /var/log/centreon/*.log
  chown centreon:centreon /var/log/centreon/*.log
fi
