FROM centos:8

ENV JAVA_HOME=/opt/jdk11
ENV PATH=${JAVA_HOME}:${PATH}

ARG DOWNLOAD=http://10.0.38.42/download

RUN yum -y install wget git
WORKDIR /opt

# JDK11 Amazon Corretto
RUN  cd /opt && \
    wget ${DOWNLOAD}/etc/amazon-corretto-11.0.5.10.1-linux-x64.tar.gz &&\
    tar -zxf amazon-corretto-11.0.5.10.1-linux-x64.tar.gz &&\
    rm -f amazon-corretto-11.0.5.10.1-linux-x64.tar.gz &&\
    ln -s amazon-corretto-11.0.5.10.1-linux-x64 jdk11

# Maven
RUN cd /opt &&\
    wget http://ftp.unicamp.br/pub/apache/maven/maven-3/3.6.2/binaries/apache-maven-3.6.2-bin.tar.gz &&\
    tar -zxf apache-maven-3.6.2-bin.tar.gz && rm -f apache-maven-3.6.2-bin.tar.gz
ENV PATH=/opt/apache-maven-3.6.2/bin:${PATH}

# Kafka
RUN cd /opt &&\
    wget ${DOWNLOAD}/etc/kafka_2.12-2.3.0.tgz &&\
    tar -zxvf kafka_2.12-2.3.0.tgz &&\
    rm -f kafka_2.12-2.3.0.tgz &&\
    ln -s kafka_2.12-2.3.0 kafka

# Phoebus alarm server
RUN cd /opt/ &&\
    git clone https://github.com/shroffk/phoebus.git
RUN cd /opt/phoebus &&\
    mvn clean verify  -f dependencies/pom.xml
#RUN cd alarm-server-product/target; java -jar alarm-server-product-0.0.1-SNAPSHOT.jar

COPY docker-entrypoint.sh /docker-entrypoint.sh

# Init stuff
CMD /bin/bash /docker-entrypoint.sh
