## Global build args

ARG ES_VERSION="6.5.4"
ARG ES_PLUGINS=""


FROM docker.elastic.co/elasticsearch/elasticsearch:${ES_VERSION}
ARG ES_VERSION
ARG ES_PLUGINS

RUN echo $ES_PLUGINS | xargs -n1 -r elasticsearch-plugin install --batch

ENV CLUSTER_NAME "elasticsearch-cluster"
ENV NODE_DATA true
ENV NODE_MASTER true
ENV NODE_INGEST true
ENV DISCOVERY_GROUP "127.0.0.1"

COPY elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
