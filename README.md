# ansible-physical-mysql-replica
Deploy MySQL Master-Slave using Physical backup strategy

Replica Server:
```
sh run_mysql_physical_replica.sh dbreplica "/var/lib/mysql/datadir" 4444 172.16.122.146 8499 1
```
* 1st param: hostname listed on hosts files
* 2nd param: mysql datadir
* 3rd param: port on the replica server used to transfer the data across master/slave.
* 4th param: master server ip address or dns
* 5th param: mysql server id
* 6th param: 0 to not configure replication and 1 to configure replication.

Master Server:
```
sh run_mysql_physical_master.sh dbmaster 172.16.122.156 4444
```

* 1st param: hostname listed on hosts files
* 2nd param: ip address or dns of the replica server
* 3rd param: port on the replica server used to transfer the data across master/slave.
