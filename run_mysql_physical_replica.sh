#!/bin/bash

export SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PYTHON_BIN=/usr/bin/python
export ANSIBLE_CONFIG=$SCRIPT_PATH/ansible.cfg

cd $SCRIPT_PATH

VAR_HOST=${1}
VAR_DATADIR=${2}
VAR_PORT=${3}
VAR_MASTER_SERVER_ADDRESS=${4}
VAR_MASTER_SERVER_ID=${5}
VAR_CONFIG_REPLICATION=${6}
VAR_LOCK_FILE="/tmp/lock_file"

if [ "${VAR_HOST}" == '' ] ; then
  echo "No host specified. Please have a look at README file for futher information!"
  exit 1
fi

if [ "${VAR_DATADIR}" == '' ] ; then
  echo "No Datadir was specified. Please have a look at README file for futher information!"
  exit 1
fi

if [ "${VAR_PORT}" == '' ] ; then
  echo "No Port specified. Please have a look at README file for futher information!"
  exit 1
fi

if [ "${VAR_MASTER_SERVER_ADDRESS}" == '' ] ; then
  echo "No Master server was specified. Please have a look at README file for futher information!"
  exit 1
fi

if [ "${VAR_MASTER_SERVER_ID}" == '' ] ; then
  echo "No Master server id was specified. Please have a look at README file for futher information!"
  exit 1
fi

if [ "${VAR_CONFIG_REPLICATION}" == '' ] ; then
  echo "No Parameter specified for replication. Please have a look at README file for futher information!"
  exit 1
fi

### Ping host ####
ansible -i $SCRIPT_PATH/hosts -m ping $VAR_HOST -v

### Run MySQL Physical replica ####
ansible-playbook -v -i $SCRIPT_PATH/hosts -e "{replica_datadir: '$VAR_DATADIR', replica_port: '$VAR_PORT', master_server_address: '$VAR_MASTER_SERVER_ADDRESS', master_server_id: '$VAR_MASTER_SERVER_ID', config_replication: '$VAR_CONFIG_REPLICATION', lock_created: $VAR_LOCK_FILE}" $SCRIPT_PATH/playbook/mysql_physical_replica.yml -l $VAR_HOST
