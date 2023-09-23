#!/bin/sh

set -e

apk add --update --no-cache httpie jq

# Get the endpoint id
echo "# Get the endpoint id"
ENDPOINT_ID=$(http --verify false \
  GET \
  $HOST/api/endpoints \
  X-API-Key:$PORTAINER_API_KEY | \
  jq -r '.[] | select(.Name=="lmserver").Id'
)
echo "ENDPOINT_ID = $ENDPOINT_ID"

# Create the container
echo "# Creating the container"
CONTAINER_ID=$(http --verify false \
  POST \
  $HOST/api/endpoints/$ENDPOINT_ID/docker/containers/create?name=hevc-portainer \
  Content-Type:application/json \
  X-API-Key:$PORTAINER_API_KEY \
  Image=melvyndekort/hevc-portainer:latest \
  Cmd[0]=/bin/sh \
  Cmd[1]=-c \
  Cmd[2]=/nextcloud-sync.sh \
  HostConfig[AutoRemove]:=true \
  HostConfig[Mounts][0][Target]=/var/run/docker.sock \
  HostConfig[Mounts][0][Source]=/var/run/docker.sock \
  HostConfig[Mounts][0][Type]=bind \
  HostConfig[Mounts][0][ReadOnly]:=true \
  HostConfig[Mounts][1][Target]=/source \
  HostConfig[Mounts][1][Source]=/var/mnt/storage/nextcloud \
  HostConfig[Mounts][1][Type]=bind \
  HostConfig[Mounts][1][ReadOnly]:=false \
  HostConfig[Mounts][2][Target]=/target \
  HostConfig[Mounts][2][Source]=/var/mnt/storage/photos \
  HostConfig[Mounts][2][Type]=bind \
  HostConfig[Mounts][2][ReadOnly]:=false | \
  jq -r '.Id'
)
echo "CONTAINER_ID = $CONTAINER_ID"

# Start the container
echo "# Starting the container"
http --verify false \
  POST \
  $HOST/api/endpoints/$ENDPOINT_ID/docker/containers/$CONTAINER_ID/start \
  Content-Type:application/json \
  X-API-Key:$PORTAINER_API_KEY \
  --raw='{}' \
  -p m

echo "Container $CONTAINER_ID started"
