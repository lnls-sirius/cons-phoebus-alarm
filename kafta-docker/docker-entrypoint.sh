#!/bin/bash
tail -f /dev/null

# Start zookeeper
(cd /opt/kafta; bin/zookeeper-server-start.sh -daemon config/zookeeper.properties)
sleep 2

# Start kafka
(cd /opt/kafta; bin/kafka-server-start.sh -daemon config/server.properties)
sleep 2

cat topics | while read _topic
do
    # Create the compacted topics.
    for topic in "$_topic"
    do
        /opt/kafka/bin/kafka-topics.sh  --zookeeper localhost:2181 --create --replication-factor 1 --partitions 1 --topic $topic
        /opt/kafka/bin/kafka-configs.sh --zookeeper localhost:2181 --entity-type topics --alter --entity-name $topic \
            --add-config cleanup.policy=compact,segment.ms=10000,min.cleanable.dirty.ratio=0.01,min.compaction.lag.ms=1000
    done

    # Create the deleted topics
    for topic in "${_topic}Command" "${_topic}Talk"
    do
        /opt/kafka/bin/kafka-topics.sh  --zookeeper localhost:2181 --create --replication-factor 1 --partitions 1 --topic $topic
        /opt/kafka/bin/kafka-configs.sh --zookeeper localhost:2181 --entity-type topics --alter --entity-name $topic \
            --add-config cleanup.policy=delete,segment.ms=10000,min.cleanable.dirty.ratio=0.01,min.compaction.lag.ms=1000,retention.ms=20000,delete.retention.ms=1000,file.delete.delay.ms=1000
    done

    (echo "Starting alarm-server for topic $topic"; cd /opt/phoebus/services/alarm-server; ./alarm-server.sh $topic -noshell)&
done