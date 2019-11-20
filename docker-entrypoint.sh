#!/bin/sh

if [ -z ${MAX_HEAP_SIZE+x} ]; then
  system_memory_in_mb=$(free -m | awk '/:/ {print $2;exit}')
  memory_limit_in_bytes=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)
  memory_limit_in_mb=$(( $memory_limit_in_bytes / 1024 / 1024 ))
  if [ "$memory_limit_in_mb" -gt "$system_memory_in_mb" ]; then
    memory_limit_in_mb="$system_memory_in_mb"
  fi
  max_heap_size_in_mb=$(( $memory_limit_in_mb / 2 ))
  export MAX_HEAP_SIZE="${max_heap_size_in_mb}M"
fi

if [ -z ${ELASTICSEARCH_JAVA_XMS+x} ]; then
  export ELASTICSEARCH_JAVA_XMS="$MAX_HEAP_SIZE"
fi
if [ -z ${ELASTICSEARCH_JAVA_XMX+x} ]; then
  export ELASTICSEARCH_JAVA_XMX="$MAX_HEAP_SIZE"
fi

confd -onetime -log-level debug || exit 2

## run elasticsearch

export ES_HOME=/usr/share/elasticsearch
export ES_PATH_CONF=/etc/elasticsearch

export CONF_DIR=/etc/elasticsearch
export DATA_DIR=/var/lib/elasticsearch
export LOG_DIR=/var/log/elasticsearch
export PID_DIR=/var/run/elasticsearch

chown -vR root:elasticsearch "$CONF_DIR"
chown -vR elasticsearch:elasticsearch "$DATA_DIR" "$LOG_DIR"

exec su-exec elasticsearch /usr/share/elasticsearch/bin/elasticsearch \
  -p ${PID_DIR}/elasticsearch.pid \
  --verbose
