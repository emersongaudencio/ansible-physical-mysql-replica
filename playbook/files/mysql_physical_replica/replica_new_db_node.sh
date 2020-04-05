#!/bin/bash
# Replica Backup Node through xtrabackup and mariabackup

### how to use it #####
# sh /tmp/replica_new_db_node.sh {{ replica_datadir }} {{ replica_port }} {{ master_server_address }} {{ master_server_id }} {{ config_replication }}

## in order of execution process
## the replica_new_db_node.sh is always first to run it and then you can run it the master_new_db_node.sh in the node who will be the donor.

verify_mysql=`rpm -qa | grep MariaDB-server`
datadir=${1}
port=${2}
MASTER_SERVER_ADDRESS=${3}
MASTER_SERVER_ID=${4}
CONFIG_REPLICATION=${5}

echo $datadir
echo $port
echo $MASTER_SERVER_ADDRESS
echo $MASTER_SERVER_ID
echo $CONFIG_REPLICATION

### restart mysql service to apply new config file generate in this stage ###
pid_mysql=$(pidof mysqld)
if [[ $pid_mysql -gt 1 ]]
then
kill -15 $pid_mysql
fi
sleep 2

# create directories for mysql datadir
rm -rf $datadir
if [ ! -d ${datadir} ]
then
    mkdir -p ${datadir}
    chmod 755 ${datadir}
    chown -Rf mysql.mysql ${datadir}
fi

if [[ $verify_mysql == "MariaDB-server-10.1"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && mariabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && mariabackup --prepare --use-memory=4G --target-dir=$datadir && chown --recursive mysql.mysql $datadir && service mysql start
MYSQL_VERSION="101"
elif [[ $verify_mysql == "MariaDB-server-10.2"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && mariabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && mariabackup --prepare --use-memory=4G --target-dir=$datadir && chown --recursive mysql.mysql $datadir && service mysql start
MYSQL_VERSION="102"
elif [[ $verify_mysql == "MariaDB-server-10.3"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && mariabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && mariabackup --prepare --use-memory=4G --target-dir=$datadir && chown --recursive mysql.mysql $datadir && service mysql start
MYSQL_VERSION="103"
elif [[ $verify_mysql == "MariaDB-server-10.4"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && mariabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && mariabackup --prepare --use-memory=4G --target-dir=$datadir && chown --recursive mysql.mysql $datadir && service mysql start
MYSQL_VERSION="104"
fi

if [[ $verify_mysql == "" ]]
then
  verify_mysql=`rpm -qa | grep mysql-community-server`
fi

if [[ $verify_mysql == "mysql-community-server-5.5"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && xtrabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && xtrabackup --prepare --use-memory=4G --target-dir=$datadir && chown --recursive mysql.mysql $datadir  && service mysqld start
MYSQL_VERSION="55"
elif [[ $verify_mysql == "mysql-community-server-5.6"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && xtrabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && xtrabackup --prepare --use-memory=4G --target-dir=$datadir && chown --recursive mysql.mysql $datadir  && service mysqld start
MYSQL_VERSION="56"
elif [[ $verify_mysql == "mysql-community-server-5.7"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && xtrabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && xtrabackup --prepare --use-memory=4G --target-dir=$datadir && chown --recursive mysql.mysql $datadir  && service mysqld start
MYSQL_VERSION="57"
elif [[ $verify_mysql == "mysql-community-server-8.0"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && xtrabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && xtrabackup --prepare --use-memory=4G --target-dir=$datadir && chown --recursive mysql.mysql $datadir  && service mysqld start
MYSQL_VERSION="80"
fi

############# generate users to configure replication and also reconfigure the default passwd from the replica server ############
### standalone instance standard users ##
SERVERID=$MASTER_SERVER_ID
REPLICATION_USER_NAME="replication_user"

### generate replication passwd #####
RD_REPLICATION_USER_PWD="replication-$SERVERID"
touch /tmp/$RD_REPLICATION_USER_PWD
echo $RD_REPLICATION_USER_PWD > /tmp/$RD_REPLICATION_USER_PWD
HASH_REPLICATION_USER_PWD=`md5sum  /tmp/$RD_REPLICATION_USER_PWD | awk '{print $1}' | sed -e 's/^[[:space:]]*//' | tr -d '/"/'`

### users pwd ##
REPLICATION_USER_PWD=$HASH_REPLICATION_USER_PWD

### generate root passwd #####
if [ "$MYSQL_VERSION" == "80" ]; then
   passwd="$SERVERID-my80"
 elif [[ "$MYSQL_VERSION" == "57" ]]; then
   passwd="$SERVERID-my57"
 elif [[ "$MYSQL_VERSION" == "56" ]]; then
   passwd="$SERVERID-my56"
 elif [[ "$MYSQL_VERSION" == "55" ]]; then
   passwd="$SERVERID-my55"
 else
   passwd="root-$SERVERID"
fi
touch /tmp/$passwd
echo $passwd > /tmp/$passwd
hash=`md5sum  /tmp/$passwd | awk '{print $1}' | sed -e 's/^[[:space:]]*//' | tr -d '/"/'`
##################################################################################################################################

### generate it the user file on root account linux #####
echo "[client]
user            = root
password        = $hash
" > /root/.my.cnf_master

if [ "$CONFIG_REPLICATION" == "1" ]; then
  ### configure and setup replication streaming between master and replica ####
  BINLOG_FILE=$(cat ${datadir}/xtrabackup_binlog_info | awk '{print $1}')
  BINLOG_POS=$(cat ${datadir}/xtrabackup_binlog_info | awk '{print $2}')
  ### setting up replicatin streaming
  mysql --defaults-file=/root/.my.cnf_master --force -e "CHANGE MASTER TO MASTER_HOST = '$MASTER_SERVER_ADDRESS' , MASTER_USER = '$REPLICATION_USER_NAME' , MASTER_PASSWORD = '$REPLICATION_USER_PWD', MASTER_LOG_FILE='$BINLOG_FILE', MASTER_LOG_POS=$BINLOG_POS;";
  mysql --defaults-file=/root/.my.cnf_master --force -e "START SLAVE;";
fi

### REMOVE TMP FILES on /tmp #####
rm -rf /tmp/*
