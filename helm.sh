#!/bin/bash

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <values_file>"
  exit 1
fi

VALUES_FILE=$1

# Copies the dockerconfigjson from the values file to the local docker config
# grep -A2 "dockerconfigjson:" $VALUES_FILE | awk '{print $2}' | tr -d '"' | base64 --decode >> ~/.docker/config.json

helm dep up charts/vaas
helm lint charts/vaas -f $VALUES_FILE
helm template charts/vaas -f $VALUES_FILE
helm upgrade --install vaas charts/vaas -f $VALUES_FILE -n vaas --create-namespace --debug
