#!/bin/bash

PROJECT_NAME=git-repo-manager
INSTANCE_NAME=sql-server-1-vm
INSTANCE_ZONE=us-central1-a
DATE_TIME=$(date "+%Y%m%d-%H%M%S")

echo Connect to GCloud
echo $GCLOUD_SERVICE_KEY | base64 --decode -i > ${HOME}/gcloud-service-key.json
gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json

gcloud --quiet config set project $PROJECT_NAME
gcloud --quiet config set compute/zone $INSTANCE_ZONE
gcloud components update
gcloud -v


# Maintenance page ON
CLOUDFLARE_AUTH_EMAIL=$CLOUDFLARE_AUTH_EMAIL CLOUDFLARE_AUTH_KEY=$CLOUDFLARE_AUTH_KEY CLOUDFLARE_DOMAIN_NAME=$CLOUDFLARE_DOMAIN_NAME CLOUDFLARE_ZONE_ID=$CLOUDFLARE_ZONE_ID MAINTENANCE_PAGE=$MAINTENANCE_PAGE node commands/maintenance.js enable

# instances stop
gcloud compute instances stop $INSTANCE_NAME \
--zone $INSTANCE_ZONE

# create a snapshot of a zonal persistent disk
gcloud compute disks snapshot $INSTANCE_NAME \
--snapshot-names $INSTANCE_NAME-$DATE_TIME \
--zone $INSTANCE_ZONE

# instances start
gcloud compute instances start $INSTANCE_NAME \
--zone $INSTANCE_ZONE