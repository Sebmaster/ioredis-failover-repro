#/bin/sh

set -euo pipefail

docker-compose down -v --remove-orphans
git checkout config/nodes*
docker-compose up -d
docker-compose exec redis1 redis-cli CLUSTER MEET $(docker-compose exec redis2 ifconfig eth0 | grep "inet " | awk -F'[: ]+' '{ print $4 }') 6379
docker-compose exec redis1 redis-cli CLUSTER MEET $(docker-compose exec redis3 ifconfig eth0 | grep "inet " | awk -F'[: ]+' '{ print $4 }') 6379
docker-compose exec redis1 redis-cli CLUSTER MEET $(docker-compose exec redis4 ifconfig eth0 | grep "inet " | awk -F'[: ]+' '{ print $4 }') 6379
docker-compose exec redis1 redis-cli CLUSTER MEET $(docker-compose exec redis5 ifconfig eth0 | grep "inet " | awk -F'[: ]+' '{ print $4 }') 6379
docker-compose exec redis1 redis-cli CLUSTER MEET $(docker-compose exec redis6 ifconfig eth0 | grep "inet " | awk -F'[: ]+' '{ print $4 }') 6379

sleep 10 # let cluster state sync

docker-compose exec redis1 redis-cli CLUSTER ADDSLOTS $(seq -s ' ' 0 6000)
docker-compose exec redis2 redis-cli CLUSTER ADDSLOTS $(seq -s ' ' 6001 12000)
docker-compose exec redis3 redis-cli CLUSTER ADDSLOTS $(seq -s ' ' 12001 16383)

sleep 20 # let cluster state sync

IP=$(docker-compose exec redis1 ifconfig eth0 | grep 'inet ' | awk -F'[: ]+' '{ print $4 }')
NODE_ID=$(docker-compose exec redis1 redis-cli CLUSTER NODES | grep "$IP" | cut -f1 -d' ')
docker-compose exec redis4 redis-cli CLUSTER REPLICATE $NODE_ID

IP=$(docker-compose exec redis2 ifconfig eth0 | grep 'inet ' | awk -F'[: ]+' '{ print $4 }')
NODE_ID=$(docker-compose exec redis1 redis-cli CLUSTER NODES | grep "$IP" | cut -f1 -d' ')
docker-compose exec redis5 redis-cli CLUSTER REPLICATE $NODE_ID

IP=$(docker-compose exec redis3 ifconfig eth0 | grep 'inet ' | awk -F'[: ]+' '{ print $4 }')
NODE_ID=$(docker-compose exec redis1 redis-cli CLUSTER NODES | grep "$IP" | cut -f1 -d' ')
docker-compose exec redis6 redis-cli CLUSTER REPLICATE $NODE_ID

