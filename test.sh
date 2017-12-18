#!/bin/sh
docker-compose exec redis1 redis-cli -c SET key value
sleep 1 # make sure we sync

docker-compose run node node redis.js &
sleep 10
PID=$!
docker-compose kill -s STOP redis3 # key hashes to 12539 so this is its master
echo "Killed Redis"
wait $PID
