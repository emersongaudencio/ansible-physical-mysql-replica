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
nc -l $port | xbstream -x -C $datadir && mariabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && mariabackup --prepare --use-memory=1G --target-dir=$datadir && chown --recursive mysql.mysql $datadir && service mysql start
MYSQL_VERSION="101"
elif [[ $verify_mysql == "MariaDB-server-10.2"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && mariabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && mariabackup --prepare --use-memory=1G --target-dir=$datadir && chown --recursive mysql.mysql $datadir && service mysql start
MYSQL_VERSION="102"
elif [[ $verify_mysql == "MariaDB-server-10.3"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && mariabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && mariabackup --prepare --use-memory=1G --target-dir=$datadir && chown --recursive mysql.mysql $datadir && service mysql start
MYSQL_VERSION="103"
elif [[ $verify_mysql == "MariaDB-server-10.4"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | mbstream -x -C $datadir && mariabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && mariabackup --prepare --use-memory=1G --target-dir=$datadir && chown --recursive mysql.mysql $datadir && service mysql start
MYSQL_VERSION="104"
elif [[ $verify_mysql == "MariaDB-server-10.5"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | mbstream -x -C $datadir && mariabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && mariabackup --prepare --use-memory=1G --target-dir=$datadir && chown --recursive mysql.mysql $datadir && service mysql start
MYSQL_VERSION="105"
fi

if [[ $verify_mysql == "" ]]
then
  verify_mysql=`rpm -qa | grep mysql-community-server`
fi

if [[ $verify_mysql == "mysql-community-server-5.5"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && xtrabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && xtrabackup --prepare --use-memory=1G --target-dir=$datadir && chown --recursive mysql.mysql $datadir  && service mysqld start
MYSQL_VERSION="55"
elif [[ $verify_mysql == "mysql-community-server-5.6"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && xtrabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && xtrabackup --prepare --use-memory=1G --target-dir=$datadir && chown --recursive mysql.mysql $datadir  && service mysqld start
MYSQL_VERSION="56"
elif [[ $verify_mysql == "mysql-community-server-5.7"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && xtrabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && xtrabackup --prepare --use-memory=1G --target-dir=$datadir && chown --recursive mysql.mysql $datadir  && service mysqld start
MYSQL_VERSION="57"
elif [[ $verify_mysql == "mysql-community-server-8.0"* ]]
then
echo "$verify_mysql is installed!"
nc -l $port | xbstream -x -C $datadir && xtrabackup --decompress --remove-original --parallel=4 --target-dir=$datadir && xtrabackup --prepare --use-memory=1G --target-dir=$datadir && chown --recursive mysql.mysql $datadir  && service mysqld start
MYSQL_VERSION="80"
fi

############# generate users to configure replication and also reconfigure the default passwd from the replica server ############
### standalone instance standard users ##
SERVERID=$MASTER_SERVER_ID

### generate replication passwd #####
RD_REPLICATION_USER_PWD="replication-$SERVERID"
touch /tmp/$RD_REPLICATION_USER_PWD
echo $RD_REPLICATION_USER_PWD > /tmp/$RD_REPLICATION_USER_PWD
HASH_REPLICATION_USER_PWD=`md5sum  /tmp/$RD_REPLICATION_USER_PWD | awk '{print $1}' | sed -e 's/^[[:space:]]*//' | tr -d '/"/'`

### users pwd ##
REPLICATION_USER_NAME="replication_user"
REPLICATION_USER_PWD=$HASH_REPLICATION_USER_PWD
##################################################################################################################################

### generate it the user file on root account linux #####
echo "[client]
user            = $REPLICATION_USER_NAME
password        = $REPLICATION_USER_PWD
" > /root/.my.cnf_replica

if [ "$CONFIG_REPLICATION" == "1" ]; then
  ### configure and setup replication streaming between master and replica ####
  BINLOG_FILE=$(cat ${datadir}/xtrabackup_binlog_info | awk '{print $1}')
  BINLOG_POS=$(cat ${datadir}/xtrabackup_binlog_info | awk '{print $2}')
  echo "BINLOG_FILE:"$BINLOG_FILE
  echo "BINLOG_POS:"$BINLOG_POS
  ### setting up replicatin streaming
  mysql --defaults-file=/root/.my.cnf_replica --force -e "RESET MASTER; CHANGE MASTER TO MASTER_HOST = '$MASTER_SERVER_ADDRESS' , MASTER_USER = '$REPLICATION_USER_NAME' , MASTER_PASSWORD = '$REPLICATION_USER_PWD', MASTER_LOG_FILE='$BINLOG_FILE', MASTER_LOG_POS=$BINLOG_POS; START SLAVE; SET GLOBAL READ_ONLY = 1; SELECT @@READ_ONLY; SHOW SLAVE STATUS\G";
  ### MySQL Section ####
  if [[ $MYSQL_VERSION == "55" ]]
  then
    #####  MYSQL READ ONLY ###########################
    check_read_only=$(cat /etc/my.cnf | grep '# readonly-mode' | wc -l)
    if [ "$check_read_only" == "0" ]; then
      echo '# readonly-mode' >> /etc/my.cnf
      echo 'read_only = 1' >> /etc/my.cnf
      echo 'innodb_flush_log_at_trx_commit = 2' >> /etc/my.cnf
    else
    echo "MySQL READ ONLY for /etc/my.cnf is already in place!"
    fi
  elif [[ $MYSQL_VERSION == "56" ]]
  then
    #####  MYSQL READ ONLY ###########################
    check_read_only=$(cat /etc/my.cnf | grep '# readonly-mode' | wc -l)
    if [ "$check_read_only" == "0" ]; then
      echo '# readonly-mode' >> /etc/my.cnf
      echo 'read_only = 1' >> /etc/my.cnf
      echo 'innodb_flush_log_at_trx_commit = 2' >> /etc/my.cnf
    else
    echo "MySQL READ ONLY for /etc/my.cnf is already in place!"
    fi
  elif [[ $MYSQL_VERSION == "57" ]]
  then
    #####  MYSQL READ ONLY ###########################
    check_read_only=$(cat /etc/my.cnf | grep '# readonly-mode' | wc -l)
    if [ "$check_read_only" == "0" ]; then
      echo '# readonly-mode' >> /etc/my.cnf
      echo 'read_only = 1' >> /etc/my.cnf
      echo 'innodb_flush_log_at_trx_commit = 2' >> /etc/my.cnf
    else
    echo "MySQL READ ONLY for /etc/my.cnf is already in place!"
    fi
  elif [[ $MYSQL_VERSION == "80" ]]
  then
    #####  MYSQL READ ONLY ###########################
    check_read_only=$(cat /etc/my.cnf | grep '# readonly-mode' | wc -l)
    if [ "$check_read_only" == "0" ]; then
      echo '# readonly-mode' >> /etc/my.cnf
      echo 'read_only = 1' >> /etc/my.cnf
      echo 'innodb_flush_log_at_trx_commit = 2' >> /etc/my.cnf
    else
    echo "MySQL READ ONLY for /etc/my.cnf is already in place!"
    fi
  fi
  ### MariaDB Section ####
  if [[ $MYSQL_VERSION == "101" ]]
  then
    echo '[mariadb]' > /etc/my.cnf.d/server_replica.cnf
    echo 'read_only = 1' >> /etc/my.cnf.d/server_replica.cnf
    echo 'innodb_flush_log_at_trx_commit = 2' >> /etc/my.cnf.d/server_replica.cnf
    echo 'log_slave_updates = 0' >> /etc/my.cnf.d/server_replica.cnf
    echo 'slave_parallel_threads = 8' >> /etc/my.cnf.d/server_replica.cnf
    echo 'slave_parallel_max_queued = 536870912' >> /etc/my.cnf.d/server_replica.cnf
  elif [[ $MYSQL_VERSION == "102" ]]
  then
    echo '[mariadb]' > /etc/my.cnf.d/server_replica.cnf
    echo 'read_only = 1' >> /etc/my.cnf.d/server_replica.cnf
    echo 'innodb_flush_log_at_trx_commit = 2' >> /etc/my.cnf.d/server_replica.cnf
    echo 'log_slave_updates = 0' >> /etc/my.cnf.d/server_replica.cnf
    echo 'slave_parallel_threads = 8' >> /etc/my.cnf.d/server_replica.cnf
    echo 'slave_parallel_max_queued = 536870912' >> /etc/my.cnf.d/server_replica.cnf
  elif [[ $MYSQL_VERSION == "103" ]]
  then
    echo '[mariadb]' > /etc/my.cnf.d/server_replica.cnf
    echo 'read_only = 1' >> /etc/my.cnf.d/server_replica.cnf
    echo 'innodb_flush_log_at_trx_commit = 2' >> /etc/my.cnf.d/server_replica.cnf
    echo 'log_slave_updates = 0' >> /etc/my.cnf.d/server_replica.cnf
    echo 'slave_parallel_threads = 8' >> /etc/my.cnf.d/server_replica.cnf
    echo 'slave_parallel_max_queued = 536870912' >> /etc/my.cnf.d/server_replica.cnf
  elif [[ $MYSQL_VERSION == "104" ]]
  then
    echo '[mariadb]' > /etc/my.cnf.d/server_replica.cnf
    echo 'read_only = 1' >> /etc/my.cnf.d/server_replica.cnf
    echo 'innodb_flush_log_at_trx_commit = 2' >> /etc/my.cnf.d/server_replica.cnf
    echo 'log_slave_updates = 0' >> /etc/my.cnf.d/server_replica.cnf
    echo 'slave_parallel_threads = 8' >> /etc/my.cnf.d/server_replica.cnf
    echo 'slave_parallel_max_queued = 536870912' >> /etc/my.cnf.d/server_replica.cnf
  elif [[ $MYSQL_VERSION == "105" ]]
  then
    echo '[mariadb]' > /etc/my.cnf.d/server_replica.cnf
    echo 'read_only = 1' >> /etc/my.cnf.d/server_replica.cnf
    echo 'innodb_flush_log_at_trx_commit = 2' >> /etc/my.cnf.d/server_replica.cnf
    echo 'log_slave_updates = 0' >> /etc/my.cnf.d/server_replica.cnf
    echo 'slave_parallel_threads = 8' >> /etc/my.cnf.d/server_replica.cnf
    echo 'slave_parallel_max_queued = 536870912' >> /etc/my.cnf.d/server_replica.cnf
  fi
fi

if [ "$CONFIG_REPLICATION" == "2" ]; then
  ### configure and setup replication streaming between master and replica ####
  BINLOG_FILE=$(cat ${datadir}/xtrabackup_binlog_info | awk '{print $1}')
  BINLOG_POS=$(cat ${datadir}/xtrabackup_binlog_info | awk '{print $2}')
  BINLOG_GTID=$(cat ${datadir}/xtrabackup_binlog_info | awk '{print $3}')
  echo "BINLOG_FILE:"$BINLOG_FILE
  echo "BINLOG_POS:"$BINLOG_POS
  echo "BINLOG_GTID:"$BINLOG_GTID
  ### setting up replicatin streaming
  mysql --defaults-file=/root/.my.cnf_replica --force -e "RESET MASTER; SET @@GLOBAL.GTID_PURGED='$BINLOG_GTID'; CHANGE MASTER TO master_host='$MASTER_SERVER_ADDRESS', master_port=3306, master_user='$REPLICATION_USER_NAME', master_password = '$REPLICATION_USER_PWD', MASTER_AUTO_POSITION=1; START SLAVE; SET GLOBAL READ_ONLY = 1; SELECT @@READ_ONLY; SHOW SLAVE STATUS\G";
  if [[ $MYSQL_VERSION == "55" ]]
  then
    #####  MYSQL READ ONLY ###########################
    check_read_only=$(cat /etc/my.cnf | grep '# readonly-mode' | wc -l)
    if [ "$check_read_only" == "0" ]; then
      echo '# readonly-mode' >> /etc/my.cnf
      echo 'read_only = 1' >> /etc/my.cnf
      echo 'innodb_flush_log_at_trx_commit = 2' >> /etc/my.cnf
    else
    echo "MySQL READ ONLY for /etc/my.cnf is already in place!"
    fi
  elif [[ $MYSQL_VERSION == "56" ]]
  then
    #####  MYSQL READ ONLY ###########################
    check_read_only=$(cat /etc/my.cnf | grep '# readonly-mode' | wc -l)
    if [ "$check_read_only" == "0" ]; then
      echo '# readonly-mode' >> /etc/my.cnf
      echo 'read_only = 1' >> /etc/my.cnf
      echo 'innodb_flush_log_at_trx_commit = 2' >> /etc/my.cnf
    else
    echo "MySQL READ ONLY for /etc/my.cnf is already in place!"
    fi
  elif [[ $MYSQL_VERSION == "57" ]]
  then
    #####  MYSQL READ ONLY ###########################
    check_read_only=$(cat /etc/my.cnf | grep '# readonly-mode' | wc -l)
    if [ "$check_read_only" == "0" ]; then
      echo '# readonly-mode' >> /etc/my.cnf
      echo 'read_only = 1' >> /etc/my.cnf
      echo 'innodb_flush_log_at_trx_commit = 2' >> /etc/my.cnf
    else
    echo "MySQL READ ONLY for /etc/my.cnf is already in place!"
    fi
  elif [[ $MYSQL_VERSION == "80" ]]
  then
    #####  MYSQL READ ONLY ###########################
    check_read_only=$(cat /etc/my.cnf | grep '# readonly-mode' | wc -l)
    if [ "$check_read_only" == "0" ]; then
      echo '# readonly-mode' >> /etc/my.cnf
      echo 'read_only = 1' >> /etc/my.cnf
      echo 'innodb_flush_log_at_trx_commit = 2' >> /etc/my.cnf
    else
    echo "MySQL READ ONLY for /etc/my.cnf is already in place!"
    fi
  fi
fi

if [ "$CONFIG_REPLICATION" == "3" ]; then
  ### configure and setup replication streaming between master and replica ####
  BINLOG_FILE=$(cat ${datadir}/xtrabackup_binlog_info | awk '{print $1}')
  BINLOG_POS=$(cat ${datadir}/xtrabackup_binlog_info | awk '{print $2}')
  BINLOG_GTID=$(cat ${datadir}/xtrabackup_binlog_info | awk '{print $3}')
  echo "BINLOG_FILE:"$BINLOG_FILE
  echo "BINLOG_POS:"$BINLOG_POS
  echo "BINLOG_GTID:"$BINLOG_GTID
  ### setting up replicatin streaming
  mysql --defaults-file=/root/.my.cnf_replica --force -e "SET GLOBAL gtid_slave_pos ='$BINLOG_GTID'; CHANGE MASTER TO MASTER_HOST='$MASTER_SERVER_ADDRESS', master_port=3306, master_user='$REPLICATION_USER_NAME', master_password = '$REPLICATION_USER_PWD', master_use_gtid=slave_pos; START SLAVE; SET GLOBAL READ_ONLY = 1; SELECT @@READ_ONLY; SHOW SLAVE STATUS\G";
  if [[ $MYSQL_VERSION == "101" ]]
  then
    echo '[mariadb]' > /etc/my.cnf.d/server_replica.cnf
    echo 'read_only = 1' >> /etc/my.cnf.d/server_replica.cnf
    echo 'innodb_flush_log_at_trx_commit = 2' >> /etc/my.cnf.d/server_replica.cnf
    echo 'log_slave_updates = 0' >> /etc/my.cnf.d/server_replica.cnf
    echo 'slave_parallel_threads = 8' >> /etc/my.cnf.d/server_replica.cnf
    echo 'slave_parallel_max_queued = 536870912' >> /etc/my.cnf.d/server_replica.cnf
  elif [[ $MYSQL_VERSION == "102" ]]
  then
    echo '[mariadb]' > /etc/my.cnf.d/server_replica.cnf
    echo 'read_only = 1' >> /etc/my.cnf.d/server_replica.cnf
    echo 'innodb_flush_log_at_trx_commit = 2' >> /etc/my.cnf.d/server_replica.cnf
    echo 'log_slave_updates = 0' >> /etc/my.cnf.d/server_replica.cnf
    echo 'slave_parallel_threads = 8' >> /etc/my.cnf.d/server_replica.cnf
    echo 'slave_parallel_max_queued = 536870912' >> /etc/my.cnf.d/server_replica.cnf
  elif [[ $MYSQL_VERSION == "103" ]]
  then
    echo '[mariadb]' > /etc/my.cnf.d/server_replica.cnf
    echo 'read_only = 1' >> /etc/my.cnf.d/server_replica.cnf
    echo 'innodb_flush_log_at_trx_commit = 2' >> /etc/my.cnf.d/server_replica.cnf
    echo 'log_slave_updates = 0' >> /etc/my.cnf.d/server_replica.cnf
    echo 'slave_parallel_threads = 8' >> /etc/my.cnf.d/server_replica.cnf
    echo 'slave_parallel_max_queued = 536870912' >> /etc/my.cnf.d/server_replica.cnf
  elif [[ $MYSQL_VERSION == "104" ]]
  then
    echo '[mariadb]' > /etc/my.cnf.d/server_replica.cnf
    echo 'read_only = 1' >> /etc/my.cnf.d/server_replica.cnf
    echo 'innodb_flush_log_at_trx_commit = 2' >> /etc/my.cnf.d/server_replica.cnf
    echo 'log_slave_updates = 0' >> /etc/my.cnf.d/server_replica.cnf
    echo 'slave_parallel_threads = 8' >> /etc/my.cnf.d/server_replica.cnf
    echo 'slave_parallel_max_queued = 536870912' >> /etc/my.cnf.d/server_replica.cnf
  elif [[ $MYSQL_VERSION == "105" ]]
  then
    echo '[mariadb]' > /etc/my.cnf.d/server_replica.cnf
    echo 'read_only = 1' >> /etc/my.cnf.d/server_replica.cnf
    echo 'innodb_flush_log_at_trx_commit = 2' >> /etc/my.cnf.d/server_replica.cnf
    echo 'log_slave_updates = 0' >> /etc/my.cnf.d/server_replica.cnf
    echo 'slave_parallel_threads = 8' >> /etc/my.cnf.d/server_replica.cnf
    echo 'slave_parallel_max_queued = 536870912' >> /etc/my.cnf.d/server_replica.cnf
  fi
fi

### REMOVE TMP FILES on /tmp #####
rm -rf /tmp/*
