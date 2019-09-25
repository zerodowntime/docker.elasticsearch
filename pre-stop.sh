#!/bin/bash -e

if [ -z ${HOSTNAME+x} ]; then
  HOSTNAME=$(hostname -s)
fi

if [ -z "$ELASTICSEARCH_NODE_NAME" ]; then
  ELASTICSEARCH_NODE_NAME=$(curl -s -X GET localhost:9200/ | jq -r .name)
fi

exclude_name=$(curl -s -X GET "http://localhost:9200/_cluster/settings" | jq -r .transient.cluster.routing.allocation.exclude._name)
if [ "$exclude_name" == "null" ]; then
  exclude_name=""
fi

exclude_name="${ELASTICSEARCH_NODE_NAME},${exclude_name}"

curl -s -XPUT -H 'Content-Type: application/json' 'localhost:9200/_cluster/settings' \
  -d '{ "transient": {"cluster.routing.allocation.exclude._name": "'$exclude_name'" } }'

while [ 1 ]; do
  allocation=$(curl -s -GET 'http://localhost:9200/_cat/allocation?format=json' | jq -r --arg this "$ELASTICSEARCH_NODE_NAME" '.[] | select(.node == $this).shards')
  if [ -z "$allocation" ]; then
    break;
  fi
  if [ "$allocation" -eq "0" ]; then
    break;
  fi
  echo "$allocation shards remaining.."
  sleep 5
done

exit 0
