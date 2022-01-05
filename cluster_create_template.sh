#!/bin/bash

echo "begin cluster_create_template.sh"

export TEMPLATE_EXISTS=$(qm list | grep -v grep | grep -ci 9000)


if [[ $TEMPLATE_EXISTS > 0 && $CREATE_TEMPLATE > 0 ]]
then
  echo "clearing template"
  # destroy any linked cluster nodes
  ./cluster_destroy_nodes.sh
  
  # could be running if in a wierd state from prior run 
  qm stop 9000 
  qm unlock 9000
  
  # destroy template
  qm destroy 9000 --purge 1
  
elif [[ $TEMPLATE_EXISTS > 0 && $CREATE_TEMPLATE == 0 ]]
then
  echo "using existing template"
  exit
fi

#fetch cloud-init image
wget -nc https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img

echo "Cluster storage: $CLUSTER_STORAGE"

# create a new VM
qm create 9000 --name k3s-template --memory 4096 --cores 4 --net0 virtio,bridge=vmbr0 
# import the downloaded disk to local storage
qm importdisk 9000 focal-server-cloudimg-amd64.img $CLUSTER_STORAGE 1>/dev/null 
# finally attach the new disk to the VM as scsi drive
qm set 9000 --scsihw virtio-scsi-pci --scsi0 $CLUSTER_STORAGE:9000/vm-9000-disk-0.raw
qm set 9000 --ide2 $CLUSTER_STORAGE:cloudinit
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
qm set 9000 --ipconfig0 ip=dhcp

qm set 9000 --cicustom "user=local:snippets/user-data.yml" 

echo "starting template vm..."
qm start 9000

echo "waiting for template vm to complete initial setup..."
secs=600
while [ $secs -gt 0 ]; do
   echo -ne "\t$secs seconds remaining\033[0K\r"
   sleep 1
   : $((secs--))
done

echo "initial setup complete..."
qm shutdown 9000
qm stop 9000

echo "creating template image"
qm template 9000
 