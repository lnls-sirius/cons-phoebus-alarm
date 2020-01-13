#!/bin/bash
set -x

wait-for-it -t 0 ${ZOO_HOST}:${ZOO_PORT}
wait-for-it -t 0 ${KAFKA_HOST}:${KAFKA_PORT}

sleep 30s
sed -i -e "s/localhost:2181/${ZOO_HOST}:${ZOO_PORT}/g" /opt/create_alarm_topics.sh
echo "Creating Accelerator topic" && cd /opt && ./create_alarm_topics.sh Accelerator

# Start Alarm Server
echo "Starting alarm-server for topic Accelerator" &&\
    cd /opt/alarm-server && \
    ./alarm-server.sh -server ${KAFKA_HOST}:${KAFKA_PORT} -config Accelerator -noshell 
