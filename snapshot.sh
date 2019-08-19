#!/bin/bash

PROJECT_NAME=git-repo-manager
INSTANCE_NAME=instance-3
DISK_NAME=instance-3
INSTANCE_ZONE=us-central1-a
DATE_TIME="$(date "+%Y%m%d-%H%M%S")" 

# Connect to GCloud
echo $GCLOUD_SERVICE_KEY | base64 --decode -i > ${HOME}/gcloud-service-key.json
gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json

gcloud --quiet config set project $PROJECT_NAME
gcloud --quiet config set compute/zone $INSTANCE_ZONE
gcloud components update
gcloud -v

# instances stop
gcloud compute instances stop $INSTANCE_NAME \
--zone $INSTANCE_ZONE

# create a snapshot of a zonal persistent disk
echo "$(gcloud compute disks snapshot $INSTANCE_NAME \
--snapshot-names $DISK_NAME-$DATE_TIME \
--zone $INSTANCE_ZONE)"

# instances start
gcloud compute instances start $INSTANCE_NAME \
--zone $INSTANCE_ZONE