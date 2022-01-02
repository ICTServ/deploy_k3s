#!/bin/bash

echo "begin cluster_create_setup.sh"

# check if .env file exists
if [[ -f ".env" ]]; then
  # read in .env file ignoring commented lines
  echo "reading in variables from .env..."
  export $(grep -v '^#' .env | xargs)
else
  echo "No .env file found at $DEPLOY_DIRECTORY!"
  echo "Exiting!"
  exit 1
fi

if [ -z "$CLUSTER_USERNAME" ] || [ -z "$CLUSTER_PASSWORD" ]; then
  echo 'one or more required variables are undefined, please check your .env file! Exiting!'        
  exit 1
fi

export CLUSTER_PASSWORD=$( openssl passwd -6 $CLUSTER_PASSWORD )


./provision_cluster.sh
 