#!/bin/bash

echo ""
exec &> >(tee -a "/usr/share/elasticsearch/logs/elasticsearch-hooks.log")

NODE_NAME=${HOSTNAME}
echo "Prepare to migrate data of the node ${NODE_NAME}"
echo "Move all data from node ${NODE_NAME}"
curl -s -XPUT -H 'Content-Type: application/json' "${MASTER_GROUP}:9200/_cluster/settings" -d "{
  \"transient\" :{
      \"cluster.routing.allocation.exclude._name\" : \"${NODE_NAME}\"
  }
}"

while true ; do
  echo -e "Wait for node ${NODE_NAME} to become empty"
  SHARDS_ALLOCATION=$(curl -s -XGET "${MASTER_GROUP}:9200/_cat/shards")
  if ! echo "${SHARDS_ALLOCATION}" | grep -E "${NODE_NAME}"; then
    break
  fi
  sleep 1
done
echo ""
echo "Node ${NODE_NAME} is ready to shutdown"
sleep 5
pkill java
