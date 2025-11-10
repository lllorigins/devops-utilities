#!/bin/bash
set -e
echo "📃 Starting healthcheck.sh"

# Name of the target service to check
service_name="$1"
# Replicas count. Defau;t: 1
replica_count=$((${2:-"1"}));
# Timeout in seconds. Default: 300
timeout=$((${3:-600}));

if [[ -z $service_name ]]; then
  echo "Service Name not Specified";
  exit 1;
fi

echo "Service: $service_name";
echo "Timeout: $timeout sec";

# Need this to make sure the docker deploy is reflected
echo "Sleeping 10s"
sleep 10;
try=0;
is_healthy="false";
while [[ $is_healthy != "true" ]];
do
  try=$(($try + 1));
  printf "🟨";
  is_healthy="false"
  health_status=$(docker inspect --format='{{json .State.Health.Status}}' $service_name)
  if [[ "$health_status" ==  "\"healthy\"" ]]; then
    is_healthy="true"
    printf "🟩\n";
    if [[ "$service_name" ==  web-ui.* ]]; then
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
