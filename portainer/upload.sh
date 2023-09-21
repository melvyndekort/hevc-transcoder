#!/bin/sh

set -e

# Get the endpoint id
echo "# Get the endpoint id"
ENDPOINT_ID=$(http --verify false \
  GET \
  $HOST/api/endpoints \
  X-API-Key:$PORTAINER_API_KEY | \
  jq -r '.[] | select(.Name=="lmserver").Id'
)
echo "ENDPOINT_ID = $ENDPOINT_ID"

# Pull the image
echo "# Pulling the image"
http --verify false \
  POST \
  $HOST/api/endpoints/$ENDPOINT_ID/docker/images/create \
  Content-Type:application/json \
  X-API-Key:$PORTAINER_API_KEY \
  fromImage==melvyndekort/hevc-portainer \
  tag==latest \
  -p m

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
  Cmd[2]=/upload.sh \
  Env[]=AWS_REGION=eu-west-1 \
  Env[]=AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  Env[]=AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  HostConfig[AutoRemove]:=true \
  HostConfig[Mounts][0][Target]=/data \
  HostConfig[Mounts][0][Source]=/var/mnt/storage/photos \
  HostConfig[Mounts][0][Type]=bind \
  HostConfig[Mounts][0][ReadOnly]:=true | \
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
