#!/bin/bash -e

if [ -z ${HOSTNAME+x} ]; then
  HOSTNAME=$(hostname -s)
fi

while ! curl -X GET "http://localhost:9200/"; do
  sleep 1
done

if [ -z "$ELASTICSEARCH_NODE_NAME" ]; then
  ELASTICSEARCH_NODE_NAME=$(curl -X GET localhost:9200/ | jq -r .name)
fi

exclude_name=$(curl -X GET "http://localhost:9200/_cluster/settings" | jq -r .transient.cluster.routing.allocation.exclude._name)
if [ "$exclude_name" == "null" ]; then
  exclude_name=""
fi

exclude_name=",${exclude_name},"
while [ 1 ]; do
  fixed="${exclude_name/,$ELASTICSEARCH_NODE_NAME,/,}"
  [ "$exclude_name" != "$fixed" ] || break
  exclude_name="$fixed"
done
exclude_name=$(echo $exclude_name | sed 's/^,*//' | sed 's/,*$//')

curl -s -XPUT -H 'Content-Type: application/json' 'localhost:9200/_cluster/settings' \
  -d '{ "transient": {"cluster.routing.allocation.exclude._name": "'$exclude_name'" } }'

exit 0
