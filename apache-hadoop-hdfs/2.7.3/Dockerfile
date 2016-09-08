FROM alpine:3.4
MAINTAINER Daniel D <djx339@gamil.com>

# Setup a volume for data
VOLUME ["/data"]

ENV HADOOP_VERSION 2.7.3

ENV JAVA_HOME /usr/lib/jvm/java-1.7-openjdk/
ENV HADOOP_HOME /hadoop
ENV HADOOP_PREFIX /hadoop
ENV HADOOP_CONF_DIR /hadoop/etc/hadoop
ENV PATH $JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

RUN mkdir -p \
        /var/run/ssh \
        /root/.ssh \
        /data

# install hadoop
RUN apk --no-cache add \
                curl=7.50.1-r0 \
                gnupg=2.1.12-r0 \
                openjdk7=7.91.2.6.3-r2 \
                openssh=7.2_p2-r3 \
    && set -x \
    && curl -SL http://mirrors.sonic.net/apache/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz -o hadoop.tar.gz \
    && curl -SL https://dist.apache.org/repos/dist/release/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz.asc -o hadoop.tar.gz.asc \
    && curl -SL https://dist.apache.org/repos/dist/release/hadoop/common/KEYS -o KEYS \
    && gpg --import KEYS \
    && gpg --verify hadoop.tar.gz.asc \
    && tar -zxC / -f hadoop.tar.gz \
    && mv /hadoop-$HADOOP_VERSION /hadoop \
    && rm hadoop.* KEYS

COPY assets /hadoop_assets

RUN cp -rvf /hadoop_assets/conf/id_rsa /hadoop_assets/conf/authorized_keys /root/.ssh \
    && cp -rvf /hadoop_assets/conf/core-site.xml /hadoop_assets/conf/hdfs-site.xml $HADOOP_CONF_DIR/ \
    && chmod a+x /hadoop_assets/runtime/*

ENTRYPOINT ["/hadoop_assets/runtime/entrypoint.sh"]
CMD ["all"]
