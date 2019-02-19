#!/bin/bash

echo ""
exec &> >(tee -a "/usr/share/elasticsearch/logs/elasticsearch-hooks.log")

NODE_NAME=${HOSTNAME}
CLUSTER_SETTINGS=$(curl -s -XGET "${MASTER_GROUP}:9200/_cluster/settings")

if echo "${CLUSTER_SETTINGS}" | grep -E "${NODE_NAME}"; then
  echo "Activate node ${NODE_NAME}"
  curl -s -XPUT -H 'Content-Type: application/json' "${MASTER_GROUP}:9200/_cluster/settings" -d "{
    \"transient\" :{
        \"cluster.routing.allocation.exclude._name\" : \"\"
    }
  }"
fi
echo ""
echo "Node ${NODE_NAME} is ready to be used"
