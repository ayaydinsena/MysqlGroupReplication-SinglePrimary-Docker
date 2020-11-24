#!/bin/bash

docker-compose down
rm -rf ./secondary/data/*
rm -rf ./secondary2/data/*
rm -rf ./primary/data/*
docker-compose build
docker-compose up -d



docker-ip() {
    docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$@"
}

docker exec mysql_primary sh -c "echo '$(docker-ip mysql_secondary) secondary' >> /etc/hosts"
echo "primary server add a secondary domain in /etc/hosts"
docker exec mysql_primary sh -c "echo '$(docker-ip mysql_secondary2) secondary2' >> /etc/hosts"
echo "primary server add a secondary2 domain in /etc/hosts"
docker exec mysql_secondary sh -c "echo '$(docker-ip mysql_primary) primary' >> /etc/hosts"
 echo "secondary server add a primary domain in /etc/hosts"
docker exec mysql_secondary sh -c "echo '$(docker-ip mysql_secondary2) secondary2' >> /etc/hosts"
echo "secondary server add a secondary2 domain in /etc/hosts"
docker exec mysql_secondary2 sh -c "echo '$(docker-ip mysql_primary) primary' >> /etc/hosts"
echo "secondary2 server add a master domain in /etc/hosts"
docker exec mysql_secondary2 sh -c "echo '$(docker-ip mysql_secondary) secondary' >> /etc/hosts"
 echo "secondary2 server add a secondary domain in /etc/hosts"
 

until docker-compose exec mysql_primary sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for mysql_primary database connection..."
    sleep 4
done
priv_stsl="SET SQL_LOG_BIN=0; GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%'; FLUSH PRIVILEGES; SET SQL_LOG_BIN=1; CHANGE MASTER TO MASTER_USER='repl', MASTER_PASSWORD='password' FOR CHANNEL 'group_replication_recovery'; INSTALL PLUGIN group_replication SONAME 'group_replication.so'; SET GLOBAL group_replication_bootstrap_group=ON; reset master; reset slave; START GROUP_REPLICATION; SET GLOBAL group_replication_bootstrap_group=OFF;"
start_cmd='export MYSQL_PWD=111; mysql -u root -e "'
start_cmd+="$priv_stsl"
start_cmd+='"'
docker exec mysql_primary sh -c "$start_cmd"

until docker-compose exec mysql_secondary sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for mysql_secondary database connection..."
    sleep 4
done
priv_stsl="SET SQL_LOG_BIN=0; GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%'; FLUSH PRIVILEGES; SET SQL_LOG_BIN=1; CHANGE MASTER TO MASTER_USER='repl', MASTER_PASSWORD='password' FOR CHANNEL 'group_replication_recovery'; INSTALL PLUGIN group_replication SONAME 'group_replication.so'; reset master; reset slave; START GROUP_REPLICATION;"
start_cmd='export MYSQL_PWD=111; mysql -u root -e "'
start_cmd+="$priv_stsl"
start_cmd+='"'
docker exec mysql_secondary sh -c "$start_cmd"

until docker-compose exec mysql_secondary2 sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for mysql_secondary2 database connection..."
    sleep 4
done
priv_stsla="SET SQL_LOG_BIN=0; GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%'; FLUSH PRIVILEGES; SET SQL_LOG_BIN=1; CHANGE MASTER TO MASTER_USER='repl', MASTER_PASSWORD='password' FOR CHANNEL 'group_replication_recovery'; INSTALL PLUGIN group_replication SONAME 'group_replication.so'; reset master; reset slave; START GROUP_REPLICATION;"
start_cmd='export MYSQL_PWD=111; mysql -u root -e "'
start_cmd+="$priv_stsla"
start_cmd+='"'
docker exec mysql_secondary2 sh -c "$start_cmd"

docker exec mysql_primary sh -c "export MYSQL_PWD=111; mysql -u root -e 'SELECT * FROM performance_schema.replication_group_members;'"
docker exec mysql_secondary sh -c "export MYSQL_PWD=111; mysql -u root -e 'SELECT * FROM performance_schema.replication_group_members;'"
docker exec mysql_secondary2 sh -c "export MYSQL_PWD=111; mysql -u root -e 'SELECT * FROM performance_schema.replication_group_members;'"