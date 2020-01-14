#!/bin/bash
set -x

wait-for-it -t 0 ${KAFKA_HOST}:${KAFKA_PORT}
wait-for-it -t 0 ${ES_HOST}:${ES_PORT}

sleep 30s
echo "Creating ES Template" && cd /opt && es_host=${ES_HOST} es_port=${ES_PORT} sh ./create_alarm_template.sh accelerator

# Start Alarm Logger
echo "Starting alarm-server for topic Accelerator" &&\
    cd /opt/alarm-logger && \
    ./alarm-logger.sh \
        -topics Accelerator\
        -es_host ${ES_HOST}\
        -es_port ${ES_PORT}\
        -es_sniff  false   \
        -bootstrap.servers ${KAFKA_HOST}:${KAFKA_PORT}\
        -date_span_units M\
        -date_span_value 1\
        -noshell 
