#!/bin/bash
set -x

# Zookeeper defaults
if [ -z "${ZOO_HOST}" ]; then
    ZOO_HOST=$(hostname)
fi
if [ -z "${ZOO_PORT}" ]; then
    ZOO_PORT=2181
fi

# Kafka defaults
if [ -z "${KAFKA_HOST}" ]; then
    KAFKA_HOST=$(hostname)
fi
if [ -z "${KAFKA_PORT}" ]; then
    KAFKA_PORT=9092
fi

wait-for-it -t 0 ${ZOO_HOST}:${ZOO_PORT}
wait-for-it -t 0 ${KAFKA_HOST}:${KAFKA_PORT}

sleep 30s
sed -i -e "s/localhost:2181/${ZOO_HOST}:${ZOO_PORT}/g" /opt/create_alarm_topics.sh
echo "Creating Accelerator topic" && cd /opt && ./create_alarm_topics.sh Accelerator

# Start Alarm Server
echo "Starting alarm-server for topic Accelerator" &&\
    cd /opt/alarm-server && \
    ./alarm-server.sh -server ${KAFKA_HOST}:${KAFKA_PORT} -config Accelerator -noshell
