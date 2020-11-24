Docker MySQL Group Replication
========================

MySQL group replication with using Docker. 

## Run

To run this examples you will need to start containers with "docker-compose" 
and after starting setup replication. See commands inside ./build.sh. 

#### Create 3 MySQL containers single primary group replication row-based replication 

```
./build.sh

```
## Troubleshooting

#### Check Logs

```
docker-compose logs
```

#### Start containers in "normal" mode

> Go through "build.sh" and run command step-by-step.

#### Check running containers

```
docker-compose ps
```

#### Clean data dir

```
rm -rf ./primary/data/*
rm -rf ./secondary/data/*
rm -rf ./secondary2/data/*
```

#### Run command inside "mysql_primary"

```
docker exec mysql_primary sh -c 'SELECT * FROM performance_schema.replication_group_members;"'

```

#### Run command inside "mysql_secondary"

```
docker exec mysql_secondary sh -c 'SELECT * FROM performance_schema.replication_group_members;"'
```
#### Run command inside "mysql_secondary2"

```
docker exec mysql_secondary2 sh -c 'SELECT * FROM performance_schema.replication_group_members;"'
```

#### Enter into "mysql_primary"

```
docker exec -it mysql_primary bash
```

#### Enter into "mysql_secondary"

```
docker exec -it mysql_secondary bash
```
#### Enter into "mysql_secondary2"

```
docker exec -it mysql_secondary2 bash
```
