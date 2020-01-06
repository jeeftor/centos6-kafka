FROM centos:6


ARG kafka_version=2.4.0
ARG scala_version=2.12
ARG glibc_version=2.12
ARG vcs_ref=unspecified
ARG build_date=unspecified


RUN yum install -y epel-release \
    java-1.8.0-openjdk \
    java-1.8.0-openjdk-devel &&\
    yum clean all

ENV JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk.x86_64

ENV KAFKA_VERSION=$kafka_version \
    SCALA_VERSION=$scala_version \
    KAFKA_HOME=/opt/kafka \
    GLIBC_VERSION=$glibc_version


ENV PATH=${PATH}:${KAFKA_HOME}/bin


COPY download-kafka.sh start-kafka.sh broker-list.sh create-topics.sh versions.sh /tmp/

RUN yum install -y bash curl wget jq docker && yum clean all\
    && chmod a+x /tmp/*.sh \
    && mv /tmp/start-kafka.sh /tmp/broker-list.sh /tmp/create-topics.sh /tmp/versions.sh /usr/bin \
    && sync && /tmp/download-kafka.sh \
    && tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
    && rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
    && ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME} \
    && rm -rf /tmp/* || true

COPY overrides /opt/overrides

VOLUME ["/kafka"]

ENV LOG_DIR=/var/lib/kafka
ENV KAFKA_LOG4J_ROOT_LOGLEVEL=ERROR
ENV KAFKA_TOOLS_LOG4J_LOGLEVEL=ERROR

ENV KAFKA_ADVERTISED_HOST_NAME=127.0.0.1
ENV KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181
ENV KAFKA_LISTENERS=LISTENER_DOCKER://kafka:9092,LISTENER_MY_MACHINE://kafka:19092
ENV KAFKA_ADVERTISED_LISTENERS=LISTENER_DOCKER://kafka:9092,LISTENER_MY_MACHINE://localhost:19092
ENV KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=LISTENER_DOCKER:PLAINTEXT,LISTENER_MY_MACHINE:PLAINTEXT
ENV KAFKA_INTER_BROKER_LISTENER_NAME=LISTENER_DOCKER



# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["start-kafka.sh"]

# \
# && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \

# && rm glibc-${GLIBC_VERSION}.apk




# && apk add --no-cache --allow-untrusted glibc-${GLIBC_VERSION}.apk \