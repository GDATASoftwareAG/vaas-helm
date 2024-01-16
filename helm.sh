#!/bin/bash

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <values_file>"
  exit 1
fi

VALUES_FILE=$1

helm lint charts/vaas -f $VALUES_FILE
helm template charts/vaas -f $VALUES_FILE --debug
helm uninstall vaas -n vaas
helm install vaas charts/vaas -f $VALUES_FILE -n vaas --create-namespace
