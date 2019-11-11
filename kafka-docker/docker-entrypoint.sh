#!/bin/bash
set -x
IP=$(hostname)
(cd /opt/kafka &&\
    sed -i -e 's/dataDir=.*/dataDir=\/opt\/data\/zookeeper/' config/zookeeper.properties)
(cd /opt/kafka &&\
    mkdir -p /opt/data/kafka-logs &&\
    sed -i \
        -e 's/zookeeper.connection.timeout.ms=.*/zookeeper.connection.timeout.ms=300000/' \
        -e 's/log\.dirs=.*/log\.dirs=\/opt\/data\/kafka-logs/g' \
        -e "31s/.*/listeners=PLAINTEXT:\/\/${IP//\./\\\.}:9092/g" \
        config/server.properties &&\
    echo "" >> config/server.properties &&\
    echo "auto.create.topics.enable=false" >> config/server.properties)

# Start zookeeper
(echo "Starting zookeeper" && cd /opt/kafka; bin/zookeeper-server-start.sh -daemon config/zookeeper.properties)
wait-for-it -t 0 localhost:2181
sleep 5

# Start kafka
(echo "Starting Kafta" && cd /opt/kafka; bin/kafka-server-start.sh -daemon config/server.properties)
wait-for-it -t 0 ${IP}:9092

(echo "Creating Accelerator topic" && cd /opt/phoebus/app/alarm/examples/ && ln -s /opt/kafka . && ./create_alarm_topics.sh Accelerator)

# Start Alarm Server
echo "Starting alarm-server for topic Accelerator" &&\
    cd /opt/phoebus/services/alarm-server && \
    ./alarm-server.sh -server ${IP}:9092 -config Accelerator -noshell &

# Config Log
aux=$IP:9092
cat > '/opt/phoebus/services/alarm-config-logger/settings.ini' << EOF
bootstrap.servers=${aux}
alarm_topics=Accelerator
local.location=/opt/alarm-config-repo
remote.location=
username=username
password=password
EOF

mkdir -p /opt/alarm-config-repo &&\
    echo "Starting alarm-config-logger for topic Accelerator" &&\
    cd /opt/phoebus/services/alarm-config-logger &&\
    java -jar target/service-alarm-config-logger-*.jar -properties /opt/phoebus/services/alarm-config-logger/settings.ini &

# Elasticsearch
cat > '/opt/elasticsearch/config/elasticsearch.yml' << EOF
transport.host: localhost
network.host: 0.0.0.0
http.port: 9200
EOF

( echo "Starting Elasticsearch" && runuser -m elastic -c 'cd /opt/elasticsearch && ./bin/elasticsearch' )&
wait-for-it -t 0 ${IP}:9200

( cd /opt/phoebus/services/alarm-logger/startup && sh create_alarm_index.sh accelerator)

cat > '/opt/phoebus/services/alarm-logger/settings.properties' << EOF
alarm_topics=Accelerator
es_host=localhost
es_port=9200
es_max_size=1000
es_sniff=false
bootstrap.servers=localhost:9092
date_span_units=M
date_span_value=1
EOF
sed -i -e "s/localhost/$IP/g" /opt/phoebus/services/alarm-logger/settings.properties

( cd /opt/phoebus/services/alarm-logger && \
    java -jar target/service-alarm-logger*.jar \
        -properties /opt/phoebus/services/alarm-logger/settings.properties \
        -noshell )

tail -f /dev/null
