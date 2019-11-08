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
ENV PATH=${JAVA_HOME}/bin:${PATH}
RUN cd /opt/phoebus && mvn -DskipTests clean install

# Elastic 7
RUN useradd elastic && groupadd -f elastic && usermod -aG elastic elastic
# RUN rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
# COPY elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo
# RUN yum -y install elasticsearch
# RUN chown -R elastic:elastic /etc/elasticsearch &&\
#     chown -R elastic:elastic /usr/share/elasticsearch &&\
#     chown -R elastic:elastic /var/log/elasticsearch &&\
#     chown -R elastic:elastic /var/lib/elasticsearch &&\
#     chown -R elastic:elastic /etc/sysconfig/elasticsearch &&\
#     chmod +x /usr/share/elasticsearch/bin/elasticsearch

# Elastic 6
RUN curl -L -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.8.4.tar.gz
RUN ln -s elasticsearch-6.8.4 elasticsearch &&\
    tar -xvf elasticsearch-6.8.4.tar.gz &&\
    chown -R elastic:elastic /opt/elasticsearch-6.8.4 &&\
    chmod g+s /opt/elasticsearch &&\
    chmod +x /opt/elasticsearch/bin/elasticsearch

# Wait-for-it
RUN git clone https://github.com/vishnubob/wait-for-it.git &&\
    chmod +x /opt/wait-for-it/wait-for-it.sh &&\
    ln -s /opt/wait-for-it/wait-for-it.sh /bin/wait-for-it

RUN mkdir -p /opt/alarm-config-repo

COPY docker-entrypoint.sh /docker-entrypoint.sh

# Init stuff
CMD /bin/bash /docker-entrypoint.sh
