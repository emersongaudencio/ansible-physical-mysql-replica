#!/bin/bash

export SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PYTHON_BIN=/usr/bin/python
export ANSIBLE_CONFIG=$SCRIPT_PATH/ansible.cfg

cd $SCRIPT_PATH

VAR_HOST=${1}
VAR_REPLICA_ADDRESS=${2}
VAR_REPLICA_PORT=${3}
VAR_LOCK_FILE="/tmp/lock_file"

if [ "${VAR_HOST}" == '' ] ; then
  echo "No host was specified. Please have a look at README file for futher information!"
  exit 1
fi

if [ "${VAR_REPLICA_ADDRESS}" == '' ] ; then
  echo "No Replica Server was specified. Please have a look at README file for futher information!"
  exit 1
fi

if [ "${VAR_REPLICA_PORT}" == '' ] ; then
  echo "No Replica port was specified. Please have a look at README file for futher information!"
  exit 1
fi

### Ping host ####
ansible -i $SCRIPT_PATH/hosts -m ping $VAR_HOST -v

### Run MySQL Physical master ####
ansible-playbook -v -i $SCRIPT_PATH/hosts -e "{replica_address: '$VAR_REPLICA_ADDRESS', replica_port: '$VAR_REPLICA_PORT', lock_created: $VAR_LOCK_FILE}" $SCRIPT_PATH/playbook/mysql_physical_master.yml -l $VAR_HOST
