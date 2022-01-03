#!/bin/bash
echo "begin provision_cluster.sh"

# updated from https://pve.proxmox.com/wiki/Cloud-Init_Support
# man pages for qm command: https://pve.proxmox.com/pve-docs/qm.1.html
# install tools
#apt install cloud-init

# generate an ssh key if one does not already exist
if [ ! -f ~/.ssh/id_ed25519 ]; then
  echo "generating ssh key in ~/.ssh/id_ed25519 with comment k3s@cluster.key"
  ssh-keygen -a 100 -t ed25519 -N '' -f ~/.ssh/id_ed25519 -C "k3s@cluster.key"
  chmod 700 ~/.ssh/id_ed25519*
fi
export CLUSTER_PUBKEY=`cat ~/.ssh/id_ed25519.pub`

# create the cloud-init user-data.yml file from template
#curl -s $GIST_REPO_ADDRESS/raw/user-data.yml?$(date +%s) | envsubst > /var/lib/vz/snippets/user-data.yml
cat user-data.yml | envsubst > /var/lib/vz/snippets/user-data.yml

echo "creating template"
# provision proxmox template
./cluster_create_template.sh
#provision worker nodes
./cluster_create_vms_worker.sh