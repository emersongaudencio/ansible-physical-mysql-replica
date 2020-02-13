#!/bin/bash
# Master Backup Node through xtrabackup and mariabackup

### how to use it #####
# ps: the ip address in this parameter has to be the new node who it intend to synchronize using this script.
# sh manual_master_new_db_node.sh 192.168.1.100

## in order of execution process
## the manual_replica_new_db_node.sh is always first and then you can run it the manual_master_new_db_node.sh in the node who will be the donor in the cluster.

verify_mysql=`rpm -qa | grep MariaDB-server`
port=4444
ip_address_new_node=$1

if [[ $verify_mysql == "MariaDB-server-10.0"* ]]
then
echo "$verify_mysql is installed!"
xtrabackup --backup  --target-dir=./ --parallel=4 --compress --compress-threads=4 --stream=xbstream | nc $ip_address_new_node $port
fi

if [[ $verify_mysql == "MariaDB-server-10.1"* ]]
then
echo "$verify_mysql is installed!"
xtrabackup --backup  --target-dir=./ --parallel=4 --compress --compress-threads=4 --stream=xbstream | nc $ip_address_new_node $port
fi

if [[ $verify_mysql == "MariaDB-server-10.2"* ]]
then
echo "$verify_mysql is installed!"
mariabackup --backup  --target-dir=./ --parallel=4 --compress --compress-threads=4 --stream=xbstream | nc $ip_address_new_node $port
fi

if [[ $verify_mysql == "MariaDB-server-10.3"* ]]
then
echo "$verify_mysql is installed!"
mariabackup --backup  --target-dir=./ --parallel=4 --compress --compress-threads=4 --stream=xbstream | nc $ip_address_new_node $port
fi

if [[ $verify_mysql == "MariaDB-server-10.4"* ]]
then
echo "$verify_mysql is installed!"
mariabackup --backup  --target-dir=./ --parallel=4 --compress --compress-threads=4 --stream=xbstream | nc $ip_address_new_node $port
fi

if [[ verify_mysql == "" ]]
then
  verify_mysql=`rpm -qa | grep mysql-community-server`
fi

if [[ $verify_mysql == "mysql-community-server-5.5"* ]]
then
echo "$verify_mysql is installed!"
xtrabackup --backup  --target-dir=./ --parallel=4 --compress --compress-threads=4 --stream=xbstream | nc $ip_address_new_node $port
fi

if [[ $verify_mysql == "mysql-community-server-5.6"* ]]
then
echo "$verify_mysql is installed!"
xtrabackup --backup  --target-dir=./ --parallel=4 --compress --compress-threads=4 --stream=xbstream | nc $ip_address_new_node $port
fi

if [[ $verify_mysql == "mysql-community-server-5.7"* ]]
then
echo "$verify_mysql is installed!"
xtrabackup --backup  --target-dir=./ --parallel=4 --compress --compress-threads=4 --stream=xbstream | nc $ip_address_new_node $port
fi

if [[ $verify_mysql == "mysql-community-server-8.0"* ]]
then
echo "$verify_mysql is installed!"
xtrabackup --backup  --target-dir=./ --parallel=4 --compress --compress-threads=4 --stream=xbstream | nc $ip_address_new_node $port
fi

