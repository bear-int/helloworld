#!/bin/bash

PROJECT_NAME=git-repo-manager
INSTANCE_NAME=instance-3
DISK_NAME=instance-3
SNAPSHOT_DISK_NAME=gcloud compute snapshots list | grep 
INSTANCE_ZONE=us-central1-a
SNAPSHOT_NAME=snapshot-1
DISK_SIZE=100

echo Connect to GCloud
# echo $GCLOUD_SERVICE_KEY | base64 --decode -i > ${HOME}/gcloud-service-key.json
# gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json

gcloud --quiet config set project $PROJECT_NAME
gcloud --quiet config set compute/zone $INSTANCE_ZONE

gcloud components update
gcloud -v

# instances stop
# gcloud compute instances stop $INSTANCE_NAME \
# --zone $INSTANCE_ZONE

# create a new regional or zonal persistent disk from your snapshot
gcloud compute disks create $SNAPSHOT_DISK_NAME \
--size $DISK_SIZE \
--source-snapshot $SNAPSHOT_NAME \
--zone $INSTANCE_ZONE \
--type pd-standard

# detach-disk
gcloud compute instances detach-disk $INSTANCE_NAME \
--disk $DISK_NAME \
--zone $INSTANCE_ZONE

# attach-disk
gcloud compute instances attach-disk $INSTANCE_NAME --disk $SNAPSHOT_DISK_NAME --boot --zone $INSTANCE_ZONE 

# instances start
# gcloud compute instances start $INSTANCE_NAME \
# --zone $INSTANCE_ZONE

# CLOUDFLARE_AUTH_EMAIL=$CLOUDFLARE_AUTH_EMAIL CLOUDFLARE_AUTH_KEY=$CLOUDFLARE_AUTH_KEY CLOUDFLARE_DOMAIN_NAME=$CLOUDFLARE_DOMAIN_NAME CLOUDFLARE_ZONE_ID=$CLOUDFLARE_ZONE_ID MAINTENANCE_PAGE=$MAINTENANCE_PAGE node commands/maintenance.js disable