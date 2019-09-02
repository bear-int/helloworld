#!/bin/bash

PROJECT_NAME=git-repo-manager
ZONE=us-central1-a
DOCKER_IMAGE_NAME=angular-intro
CLUSTER=angular-intro

echo "docker build"
docker build -t gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME:$TRAVIS_COMMIT .

echo $GCLOUD_SERVICE_KEY | base64 --decode -i > ${HOME}/gcloud-service-key.json
gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json

gcloud --quiet config set project $PROJECT_NAME
gcloud --quiet config set compute/zone $ZONE

echo "docker push"
gcloud docker -- push gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME:$TRAVIS_COMMIT
gcloud container clusters get-credentials $CLUSTER --zone $ZONE --project $PROJECT_NAME
yes | gcloud beta container images add-tag gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME:$TRAVIS_COMMIT gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME:latest

echo "Create firewall-rules"
gcloud compute firewall-rules create port-forwarding-80 \
    --action allow \
    --rules tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --priority 1000


echo Create cluster 4 pods
gcloud beta container clusters create $CLUSTER \
   --zone $ZONE \
   --node-locations $ZONE \
   --num-nodes 1 





#ROLLING UPDATE Существующий кластер

# echo "docker build"
# docker build -t gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME:$TRAVIS_COMMIT .

# echo $GCLOUD_SERVICE_KEY | base64 --decode -i > ${HOME}/gcloud-service-key.json
# gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json

# gcloud --quiet config set project $PROJECT_NAME
# gcloud --quiet config set compute/zone $ZONE

# echo "docker push"
# gcloud docker -- push gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME:$TRAVIS_COMMIT

# gcloud container clusters get-credentials $CLUSTER --zone $ZONE --project $PROJECT_NAME

# yes | gcloud beta container images add-tag gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME:$TRAVIS_COMMIT gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME:latest

# kubectl config view
# kubectl config current-context

# kubectl set image deployment/rep  rep=gcr.io/$PROJECT_NAME/$DOCKER_IMAGE_NAME:$TRAVIS_COMMIT

