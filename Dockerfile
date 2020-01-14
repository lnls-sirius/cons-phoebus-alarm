FROM openjdk:11.0.5-jdk-stretch as server

WORKDIR /opt

RUN apt-get update && apt-get install -y wget git maven

# Wait-for-it
RUN git clone https://github.com/vishnubob/wait-for-it.git &&\
    chmod +x /opt/wait-for-it/wait-for-it.sh &&\
    ln -s /opt/wait-for-it/wait-for-it.sh /bin/wait-for-it

# Kafka
ENV KAFTA_URL https://www-us.apache.org/dist/kafka/2.4.0/kafka_2.11-2.4.0.tgz
RUN cd /opt && wget ${KAFTA_URL} &&\
    tar -zxvf kafka_2.11-2.4.0.tgz && rm -f kafka_2.11-2.4.0.tgz &&\
    ln -s kafka_2.11-2.4.0 kafka

# Phoebus alarm server
RUN cd /opt && wget https://controlssoftware.sns.ornl.gov/css_phoebus/nightly/alarm-server-4.6.0.zip &&\
    unzip alarm-server-4.6.0.zip && rm -f alarm-server-4.6.0.zip && mv alarm-server-4.6.0 alarm-server

COPY phoebus/app/alarm/examples/create_alarm_topics.sh /opt/create_alarm_topics.sh
COPY docker-entrypoint.sh /docker-entrypoint.sh

# Init stuff
CMD /bin/bash /docker-entrypoint.sh

FROM openjdk:11.0.5-jdk-stretch as logger

WORKDIR /opt

# Wait-for-it
RUN git clone https://github.com/vishnubob/wait-for-it.git &&\
    chmod +x /opt/wait-for-it/wait-for-it.sh &&\
    ln -s /opt/wait-for-it/wait-for-it.sh /bin/wait-for-it

# Phoebus alarm logger
RUN cd /opt && wget https://controlssoftware.sns.ornl.gov/css_phoebus/nightly/alarm-logger-4.6.0.zip &&\
    unzip alarm-logger-4.6.0.zip && rm -f alarm-logger-4.6.0.zip && mv alarm-logger-4.6.0 alarm-logger

COPY phoebus/services/alarm-logger/startup/create_alarm_template.sh /opt/create_alarm_template.sh
COPY phoebus/services/alarm-logger/startup/create_alarm_index.sh    /opt/create_alarm_index.sh

RUN chmod +x /opt/create_alarm_template.sh && sed -i -e '/es_host=localhost/d' -e '/es_port=9200/d' /opt/create_alarm_template.sh &&\
    chmod +x /opt/create_alarm_index.sh    && sed -i -e '/es_host=localhost/d' -e '/es_port=9200/d' /opt/create_alarm_index.sh

COPY docker-entrypoint-logger.sh /docker-entrypoint.sh

CMD /bin/bash /docker-entrypoint.sh
