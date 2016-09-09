FROM ubuntu:14.04
MAINTAINER Daniel D <djx339@gamil.com>

# Setup a volume for data
VOLUME ["/data"]

ENV HADOOP_VERSION 2.7.3

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
ENV HADOOP_HOME /hadoop
ENV HADOOP_PREFIX /hadoop
ENV HADOOP_CONF_DIR /hadoop/etc/hadoop
ENV PATH $JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

RUN mkdir -p \
        /var/run/sshd \
        /root/.ssh \
        /data

# install applications
RUN apt-get update && apt-get install -y --no-install-recommends \
                curl \
                jq \
                openjdk-7-jre-headless \
                openssh-server \
                rsync \
    && rm -rf /var/lib/apt/lists/* \
    && set -x \
    && mkdir -p /hadoop \
    && curl -SL http://mirrors.sonic.net/apache/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz -o hadoop.tar.gz \
    && curl -SL https://dist.apache.org/repos/dist/release/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz.asc -o hadoop.tar.gz.asc \
    && curl -SL https://dist.apache.org/repos/dist/release/hadoop/common/KEYS -o KEYS \
    && gpg --import KEYS \
    && gpg --verify hadoop.tar.gz.asc \
    && tar -zxC /hadoop --strip-components=1 -f hadoop.tar.gz \
    && rm hadoop.* KEYS

COPY assets /hadoop_assets

RUN cp -rvf /hadoop_assets/conf/id_rsa /hadoop_assets/conf/authorized_keys /root/.ssh \
    && cp -rvf /hadoop_assets/conf/core-site.xml /hadoop_assets/conf/hdfs-site.xml $HADOOP_CONF_DIR/ \
    && chmod a+x /hadoop_assets/runtime/*

ENTRYPOINT ["/hadoop_assets/runtime/entrypoint.sh"]
CMD ["namenode"]
