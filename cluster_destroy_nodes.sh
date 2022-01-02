# DO NOT RUN THIS DIRECTLY
# IT'S CALLED BY OTHER SCRIPTS 
echo "begin cluster_destroy_nodes.sh"

source .env

## declare an array variable
declare -a arr=("3001" "3002" "3003" "3101" "3102" "3103")

## now loop through the above array
for VMID in "${arr[@]}"
do
  # check if vm exists and destroy it
  if (( $(qm list | grep -v grep | grep -ci $VMID) > 0 )); then
    qm stop $VMID
    qm unlock $VMID
    qm destroy $VMID --purge 1 
  fi
done

## declare an array variable
declare -a arr=("$CLUSTER_IP_1" "$CLUSTER_IP_2" "$CLUSTER_IP_3" "$CLUSTER_IP_4" "$CLUSTER_IP_5" "$CLUSTER_IP_6")

## now loop through the above array
for IP in "${arr[@]}"
do
  ssh-keygen -R $IP > /dev/null 2>&1
done
