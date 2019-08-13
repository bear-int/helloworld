#!/bin/bash

PROJECT_NAME=git-repo-manager
INSTANCE_NAME=instance-3
DISK_NAME=instance-3

INSTANCE_ZONE=us-central1-a
SNAPSHOT_NAME=snapshot-1


echo Connect to GCloud
echo $GCLOUD_SERVICE_KEY | base64 --decode -i > ${HOME}/gcloud-service-key.json
gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json

gcloud --quiet config set project $PROJECT_NAME
gcloud --quiet config set compute/zone $INSTANCE_ZONE

# instances stop
gcloud compute instances stop $INSTANCE_NAME \
--zone $INSTANCE_ZONE

# create a snapshot of a zonal persistent disk
gcloud compute disks snapshot $DISK_NAME \
--snapshot-names $SNAPSHOT_NAME \
--zone $INSTANCE_ZONE

# instances start
gcloud compute instances start $INSTANCE_NAME \
--zone $INSTANCE_ZONE