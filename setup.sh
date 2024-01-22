#!/bin/bash

source prepare.sh

cat > ./docker-compose.yaml <<EOF
version: "3.0"

services:
EOF

echo "MYSQL_ENABLE: ${MYSQL_ENABLE}"
if [[ ${MYSQL_ENABLE} == 'true' ]]; then
    cat >> ./docker-compose.yaml <<EOF
  mysql8:
    image: mysql:8.0
    restart: always
    command: --default-authentication-plugin=mysql_native_password
    environment:
      MYSQL_ROOT_PASSWORD: root
    volumes:
      # 设置初始化脚本
      - ./scripts/mysql/:/docker-entrypoint-initdb.d/
    ports:
      # 注意这里我映射为了 13306 端口
      - "13306:3306"

EOF
fi


echo "REDIS_ENABLE: ${REDIS_ENABLE}"
if [[ ${REDIS_ENABLE} == 'true' ]]; then
    cat >> ./docker-compose.yaml <<EOF
  redis:
    image: 'bitnami/redis:latest'
    environment:
      - ALLOW_EMPTY_PASSWORD=yes
    ports:
      - '6379:6379'

EOF
fi


echo "CONSUL_ENABLE: ${CONSUL_ENABLE}"
if [[ ${CONSUL_ENABLE} == 'true' ]]; then
    cat >> ./docker-compose.yaml <<EOF
  consul:
    image: consul:latest
    ports:
      - 8300:8300
      - 8500:8500
      - 8301:8301
      - 8301:8301/udp
      - 8302:8302
      - 8302:8302/udp
      - 8600:8600
      - 8600:8600/udp
    # volumes:
    #   - ${PWD}/config:/consul/config
    #   - ${DATA_STORAGE_PATH}/consul/data:/consul/data
    restart: always
    command: agent -dev -client=0.0.0.0

EOF
fi