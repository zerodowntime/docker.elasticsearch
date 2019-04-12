##
## author: Piotr Stawarski <piotr.stawarski@zerodowntime.pl>
##

FROM zerodowntime/centos:7.6.1810

RUN curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o /usr/local/bin/jq \
    && chmod +x /usr/local/bin/jq

ARG ELASTICSEARCH_VERSION

RUN yum -y install \
      java-1.8.0 \
      https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ELASTICSEARCH_VERSION.rpm \
    && yum clean all \
    && rm -rf /var/cache/yum /var/tmp/* /tmp/*

ARG ELASTICSEARCH_PLUGINS

RUN echo $ELASTICSEARCH_PLUGINS | xargs -rtn1 /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch

VOLUME /var/lib/elasticsearch
VOLUME /var/log/elasticsearch

# 9200: client
# 9300: cluster
EXPOSE 9200 9300

COPY confd/ /etc/confd
COPY docker-entrypoint.sh /

COPY post-start.sh        /opt/
COPY pre-stop.sh          /opt/
COPY liveness-probe.sh    /opt/
COPY readiness-probe.sh   /opt/

ENTRYPOINT ["/docker-entrypoint.sh"]
