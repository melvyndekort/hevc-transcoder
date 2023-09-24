#!/bin/sh

set -e

apk add --update --no-cache httpie jq

# Get the endpoint id
echo "# Get the endpoint id"
ENDPOINT_ID=$(http --verify false \
  GET \
  $PORTAINER_HOST/api/endpoints \
  X-API-Key:$PORTAINER_API_KEY | \
  jq -r '.[] | select(.Name=="lmserver").Id'
)
echo "ENDPOINT_ID = $ENDPOINT_ID"

# Create the container
echo "# Creating the container"
CONTAINER_ID=$(http --verify false \
  POST \
  $PORTAINER_HOST/api/endpoints/$ENDPOINT_ID/docker/containers/create?name=hevc-portainer \
  Content-Type:application/json \
  X-API-Key:$PORTAINER_API_KEY \
  Image=melvyndekort/hevc-portainer:latest \
  Cmd[0]=/bin/sh \
  Cmd[1]=-c \
  Cmd[2]=/nextcloud-sync.sh \
  Env[]=NC_PASS_melvyndekort=$NC_PASS_melvyndekort \
  Env[]=NC_PASS_kaatjeislief=$NC_PASS_kaatjeislief \
  Env[]=NC_PASS_daandekort=$NC_PASS_daandekort \
  HostConfig[AutoRemove]:=true \
  HostConfig[Mounts][0][Target]=/target \
  HostConfig[Mounts][0][Source]=/var/mnt/storage/photos \
  HostConfig[Mounts][0][Type]=bind \
  HostConfig[Mounts][0][ReadOnly]:=false | \
  jq -r '.Id'
)
echo "CONTAINER_ID = $CONTAINER_ID"

# Connect the container to the correct network
echo "# Connect the container to the correct network"
http --verify false \
  POST \
  $PORTAINER_HOST/api/endpoints/$ENDPOINT_ID/docker/networks/lmserver_default/connect \
  Content-Type:application/json \
  X-API-Key:$PORTAINER_API_KEY \
  Container=$CONTAINER_ID

# Start the container
echo "# Starting the container"
http --verify false \
  POST \
  $PORTAINER_HOST/api/endpoints/$ENDPOINT_ID/docker/containers/$CONTAINER_ID/start \
  Content-Type:application/json \
  X-API-Key:$PORTAINER_API_KEY \
  --raw='{}' \
  -p m

echo "Container $CONTAINER_ID started"
