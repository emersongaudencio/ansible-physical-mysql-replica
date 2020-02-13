#!/bin/bash
# Replica Backup Node through xtrabackup and mariabackup

### how to use it #####
# sh manual_replica_new_db_node.sh /var/lib/mysql/datadir

## in order of execution process
## the manual_replica_new_db_node.sh is always first and then you can run it the manual_master_galera_node.sh in the node who will be the donor in the cluster.

verify_mysql=`rpm -qa | grep MariaDB-server`
port=4444
datadir=$1

if [[ $verify_mysql == "MariaDB-server-10.0"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && xtrabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && xtrabackup --prepare --use-memory=4G --target-dir=$datadir && chown --recursive mysql.mysql $datadir  && service mysql start
fi

if [[ $verify_mysql == "MariaDB-server-10.1"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && xtrabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && xtrabackup --prepare --use-memory=4G --target-dir=$datadir && chown --recursive mysql.mysql $datadir && service mysql start
fi

if [[ $verify_mysql == "MariaDB-server-10.2"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && mariabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && mariabackup --prepare --use-memory=4G --target-dir=$datadir && chown --recursive mysql.mysql $datadir && service mysql start
fi

if [[ $verify_mysql == "MariaDB-server-10.3"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && mariabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && mariabackup --prepare --use-memory=4G --target-dir=$datadir && chown --recursive mysql.mysql $datadir && service mysql start
fi

if [[ $verify_mysql == "MariaDB-server-10.4"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && mariabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && mariabackup --prepare --use-memory=4G --target-dir=$datadir && chown --recursive mysql.mysql $datadir && service mysql start
fi

if [[ verify_mysql == "" ]]
then
  verify_mysql=`rpm -qa | grep mysql-community-server`
fi

if [[ $verify_mysql == "mysql-community-server-5.5"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && xtrabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && xtrabackup --prepare --use-memory=4G --target-dir=$datadir && chown --recursive mysql.mysql $datadir  && service mysql start
fi

if [[ $verify_mysql == "mysql-community-server-5.6"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && xtrabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && xtrabackup --prepare --use-memory=4G --target-dir=$datadir && chown --recursive mysql.mysql $datadir  && service mysql start
fi

if [[ $verify_mysql == "mysql-community-server-5.7"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && xtrabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && xtrabackup --prepare --use-memory=4G --target-dir=$datadir && chown --recursive mysql.mysql $datadir  && service mysql start
fi

if [[ $verify_mysql == "mysql-community-server-8.0"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && xtrabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && xtrabackup --prepare --use-memory=4G --target-dir=$datadir && chown --recursive mysql.mysql $datadir  && service mysql start
fi

