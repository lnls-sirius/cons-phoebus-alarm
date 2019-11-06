## JDK11+ Amazon Coretto

[Download](https://d3pxv6yz143wms.cloudfront.net/11.0.5.10.1/amazon-corretto-11.0.5.10.1-linux-x64.tar.gz)

```
# cd /opt
# wget http://10.0.38.42/download/etc/amazon-corretto-11.0.5.10.1-linux-x64.tar.gz
# tar -zxf amazon-corretto-11.0.5.10.1-linux-x64.tar.gz
# ln -s amazon-corretto-11.0.5.10.1-linux-x64 jdk11
```
Configure the `JAVA_HOME` and `PATH` environment variables to point at the JDK11+
```
# export JAVA_HOME=/opt/jdk11
# export PATH=$JAVA_HOME/bin:$PATH
```
## Maven
Install maven !
```
# cd /opt
# wget http://mirror.nbtelecom.com.br/apache/maven/maven-3/3.6.2/binaries/apache-maven-3.6.2-bin.tar.gz
```
## Kafka
Install Kafka and set `KAFKA_HOME`
```
# cd /opt
# wget http://ftp.unicamp.br/pub/apache/kafka/2.3.0/kafka_2.12-2.3.0.tgz
# tar -zxvf kafka_2.12-2.3.0.tgz
# ln -s kafka_2.12-2.3.0 kafka
# export KAFKA_HOME=/opt/kafka
```
### Configuration
config/zookeeper.properties
```
# the directory where the snapshot is stored.
dataDir=/tmp/zookeeper
```
config/server.properties
```
# Timeout in ms for connecting to zookeeper defaults to 6000ms.
# Suggest a much longer time (5 minutes)
zookeeper.connection.timeout.ms=300000

# Suggest to add this to prevent automatic topic creation,
auto.create.topics.enable=false
```

### Phoebus + Alarm Server
Clone the repository at `/opt` and build (check if the environment variables `JAVA_HOME` and `PATH` are set). 
```
# git clone https://github.com/shroffk/phoebus.git
# cd phoebus
# sh run_maven.sh
```
Run this to create the topics for an "Accelerator" configuration:
```
# sh create_alarm_topics.sh Accelerator
```
You need to run one alarm server for each configuration. For the "Accelerator" configuration on localhost, simply start the alarm server service. Otherwise run -help to see options for selecting another configuration.


