#!/bin/bash

# 首先，为集群创建一个单独的docker bridge网桥
docker network create geekai_plus_network

docker-compose -f ./mysql/mysql.yaml up -d
docker-compose -f ./redis/redis.yaml up -d
docker-compose -f ./tika/tika.yaml up -d
docker-compose -f ./api/api.yaml up -d
docker-compose -f ./web/web.yaml up -d
