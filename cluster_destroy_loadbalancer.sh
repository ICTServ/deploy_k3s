# DO NOT RUN THIS DIRECTLY
# IT'S CALLED BY OTHER SCRIPTS 
echo "begin cluster_destroy_loadbalancer.sh"

source .env

# destroy existing loadbalancer image
if (( $(qm list | grep -v grep | grep -ci 3000) > 0 )); then
  qm stop 3000
  qm unlock 3000
  qm destroy 3000 --purge 1
fi

# clean up known_hosts file
ssh-keygen -R $CLUSTER_LB_IP 2>/dev/null
 