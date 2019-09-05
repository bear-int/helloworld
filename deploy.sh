#!/bin/bash

PROJECT_NAME=git-repo-manager
ZONE=us-central1-a
DOCKER_IMAGE_NAME1=angular-intro
DOCKER_IMAGE_NAME2=nginx
CLUSTER1=angular-intro
CLUSTER2=nginx
DATE_TIME=$(date "+%Y%m%d-%H%M%S")

# echo "docker build"
docker build -t gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME1:$DATE_TIME . -f Dockerfile1
docker build -t gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME2:$DATE_TIME .

# Connect to GCloud
echo $GCLOUD_SERVICE_KEY | base64 --decode -i > ${HOME}/gcloud-service-key.json
gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json

gcloud --quiet config set project $PROJECT_NAME
gcloud --quiet config set compute/zone $ZONE

# docker push
gcloud docker -- push gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME1:$DATE_TIME
yes | gcloud beta container images add-tag gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME1:$DATE_TIME gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME1:latest

gcloud docker -- push gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME2:$DATE_TIME
yes | gcloud beta container images add-tag gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME2:$DATE_TIME gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME2:latest

######### CREATE CLUSTERS ##############
#####  Create cluster angilar-intro 1 pods
gcloud container clusters create $CLUSTER1 \
   --zone $ZONE \
   --node-locations $ZONE \
   --num-nodes 1 

# Workloads
kubectl run angular-intro --image=gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME1:latest \
    --port=4200 \
    --replicas=1
# LoadBalancer
kubectl expose deployment angular-intro \
   --name $CLUSTER1 \
   --type LoadBalancer --port 80 --target-port 4200

##### Create cluster nginx 1 pods
gcloud container clusters create $CLUSTER2 \
   --zone $ZONE \
   --node-locations $ZONE \
   --num-nodes 1 

# Workloads
kubectl run nginx --image=gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME2:latest \
    --port=80 \
    --replicas=1
# LoadBalancer
kubectl expose deployment nginx \
   --name $CLUSTER2 \
   --type LoadBalancer --port 80 --target-port 80






# ROLLING UPDATE
# gcloud container clusters get-credentials $CLUSTER1 --zone $ZONE --project $PROJECT_NAME
# yes | gcloud beta container images add-tag gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME1:$DATE_TIME gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME1:latest

# kubectl config view
# kubectl config current-context
# kubectl set image deployment/angular-intro  angular-intro=gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME1:latest

# gcloud container clusters get-credentials $CLUSTER2 --zone $ZONE --project $PROJECT_NAME
# yes | gcloud beta container images add-tag gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME2:$DATE_TIME gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME2:latest

# kubectl config view
# kubectl config current-context
# kubectl set image deployment/nginx nginx=gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME2:latest