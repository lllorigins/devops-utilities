#!/bin/bash
set -e
echo "📃 Starting healthcheck.sh"

# Name of the target service to check
service_name="$1"
# Replicas count. Defau;t: 1
replica_count=$((${2:-"1"}));
# Timeout in seconds. Default: 180
timeout=$((${3:-240}));

if [ -z $service_name ]; then
  echo "Service Name not Specified";
  exit 1;
fi

echo "Service: $service_name";
echo "Replicas: $replica_count";
echo "Timeout: $timeout sec";

# Need this to make sure the docker deploy is reflected
echo "Sleeping 10s"
sleep 10;
try=0;
is_healthy="false";
while [ $is_healthy != "true" ];
do
  try=$(($try + 1));
  printf "🟨";
  is_healthy="false"
  replicas=$(docker service ls --filter name=$service_name  --format='{{json .Replicas}}')
  if [ "$replicas" ==  "\"$replica_count/$replica_count\"" ]; then
    is_healthy="true"
    printf "🟩\n";
    if [ "$service_name" ==  "lllorigins_web-ui" ]; then
        printf "🚛 Removing Maintenance Mode\n"
        sudo rm -f /var/www/lllorigins.com/public_html/common/maintenance/active.html
    fi
  fi
  if [[ $try -eq $timeout ]]; then
    printf "🟥\n"
    printf "Service did not boot within timeout";
    exit 1;
  fi
  sleep 1;
done

echo "Sleeping 10s more!"
sleep 10;