# ansible-physical-mysql-replica
## Deploy MySQL Master-Slave using Physical backup strategy

## Execution order always will be:
* Replica -> Primary

# Replica Server:
```
sh run_mysql_physical_replica.sh dbreplica "/var/lib/mysql/datadir" 4444 172.16.122.146 8499 1
```
* 1st param: hostname listed on hosts files
* 2nd param: mysql datadir
* 3rd param: port on the replica server used to transfer the data across primary/replica.
* 4th param: master server ip address or dns
* 5th param: mysql server id
* 6th param: 0 to not configure replication and 1 to configure replication.

### Parameters specification:
#### run_mysql_physical_replica.sh
Parameter    | Value           | Mandatory   | Order        | Accepted values
------------ | ------------- | ------------- | ------------- | -------------
hostname or group-name listed on hosts files | dbreplica | Yes | 1 | hosts who are placed inside of the hosts file
db mysql datadir | "/var/lib/mysql/datadir" | Yes | 2 | Please inform here the mysql datadir
db mysql port transfer | 4444 | Yes | 3 | port on the replica server used to transfer the data across primary/replica.
db mysql primary server address | 172.16.122.128 | Yes | 4 | primary server ip address or dns name respective
db mysql mysql server id | 8499 | Yes | 5 | mysql server id
db mysql configure replication | 1 | Yes | 6 | 0 to not configure replication and 1 to configure replication.

# Master Server:
```
sh run_mysql_physical_primary.sh dbmaster 172.16.122.156 4444
```

* 1st param: hostname listed on hosts files
* 2nd param: ip address or dns of the replica server
* 3rd param: port on the replica server used to transfer the data across master/slave.

### Parameters specification:
#### run_mysql_physical_primary.sh
Parameter    | Value           | Mandatory   | Order        | Accepted values
------------ | ------------- | ------------- | ------------- | -------------
hostname or group-name listed on hosts files | dbmaster | Yes | 1 | hosts who are placed inside of the hosts file
db mysql datadir | 172.16.122.156 | Yes | 2 | ip address or dns of the replica server
db mysql port transfer | 4444 | Yes | 3 | port on the replica server used to transfer the data across primary/replica.
