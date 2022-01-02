#!/bin/bash

# check if .env file exists
if [[ -f ".env" ]]; then
  # read in .env file ignoring commented lines
  echo "reading in variables from .env..."
  export $(grep -v '^#' .env | xargs)
else
  echo "No .env file found!"
  echo "Exiting!"
  exit 1
fi

echo $DEPLOY_DIRECTORY

ssh $PROXMOX_USER@$PROXMOX_HOST '$(mkdir -p $DEPLOY_DIRECTORY)' 
scp .env $PROXMOX_USER@$PROXMOX_HOST:$DEPLOY_DIRECTORY/.
scp *.sh $PROXMOX_USER@$PROXMOX_HOST:$DEPLOY_DIRECTORY/.
scp *.yml $PROXMOX_USER@$PROXMOX_HOST:$DEPLOY_DIRECTORY/.

#ssh $PROXMOX_USER@$PROXMOX_HOST $DEPLOY_DIRECTORY/proxmox_k3s_cluster.sh