#!/bin/bash

source .env

echo "begin cluster_create_vms_worker.sh"

# destroy any old nodes before we start
./cluster_destroy_nodes.sh


# lets get this party started
declare -a clusterIds=("3001" "3002" "3003" "3101" "3102" "3103")
declare -a clusterAddrs=("$CLUSTER_IP_1" "$CLUSTER_IP_2" "$CLUSTER_IP_3" "$CLUSTER_IP_4" "$CLUSTER_IP_5" "$CLUSTER_IP_6")

len=${#clusterIds[@]}

## resize disks and start VMs
for (( i=0; i < $len; i++));
do
    echo "creating $k3s-${clusterIds[$i]} : ${clusterAddrs[$i]}"
    # clone images for master nodes
    qm clone 9000 ${clusterIds[$i]}  --name k3s-${clusterIds[$i]} 
    qm set ${clusterIds[$i]}  --onboot 0 --cicustom "user=local:snippets/user-data.yml" --memory 4096 --ipconfig0 ip=${clusterAddrs[$i]}/24,gw=$CLUSTER_GW_IP

    qm resize ${clusterIds[$i]}  scsi0 96G
    qm start ${clusterIds[$i]} 
done

echo "waiting for nodes to spin up..."
secs=240
while [ $secs -gt 0 ]; do
   echo -ne "\t$secs seconds remaining\033[0K\r"
   sleep 1
   : $((secs--))
done

echo "Save VM keys to known hosts"
for IP in "${clusterAddrs[@]}"
do
  echo "scraping ssh keys $IP"
  ssh-keyscan -H $IP  2> /dev/null >>example_hosts
  ssh-keyscan -H $IP 2> /dev/null >> ~/.ssh/known_hosts 
done
