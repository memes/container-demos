#!/bin/sh
#
# Start a cluster for pi-testing

PROJECT=${PROJECT:-"memes-sandbox"}
REGION=${REGION:-"us-west1"}
INITIAL_NODES=${INITIAL_NODES:-3}
MIN_NODES=${MIN_NODES:-1}
MAX_NODES=${MAX_NODES:-100}
DISK_SIZE=${DISK_SIZE:-20}

# Get zones based on region
_ZONES=$(gcloud compute zones list --filter="region:${REGION}" | shuf | awk '/UP$/ {printf "%s%s",comma,$1; comma=","}')
_NUM_ZONES=$(echo $_ZONES | awk -F, '{print NF}')
_MAIN_ZONE=${_ZONES%%,*}
_OTHER_ZONES=${_ZONES#*,}

# Adjust for number of zones
_INITIAL_NODES_PER_ZONE=$((${INITIAL_NODES} / ${_NUM_ZONES}))
[ -z "${_INITIAL_NODES_PER_ZONE}" -o "${_INITIAL_NODES_PER_ZONE}" = "0" ] && \
    _INITIAL_NODES_PER_ZONE="1"
_MIN_NODES_PER_ZONE=$((${MIN_NODES} / ${_NUM_ZONES}))
[ -z "${_MIN_NODES_PER_ZONE}" -o "${_MIN_NODES_PER_ZONE}" = "0" ] && \
    _MIN_NODES_PER_ZONE="1"
_MAX_NODES_PER_ZONE=$((${MAX_NODES} / ${_NUM_ZONES} ))
[ -z "${_MAX_NODES_PER_ZONE}" -o "${_MAX_NODES_PER_ZONE}" = "0" ] && \
    _MAX_NODES_PER_ZONE="${_MIN_NODES_PER_ZONE}"

# Create a cluster to contain node-pools using pre-emptible instances
gcloud beta container --project ${PROJECT} \
     clusters create pi-service-cluster \
     --preemptible \
     --zone=${_MAIN_ZONE} \
     ${_OTHER_ZONES:+"--additional-zones=${_OTHER_ZONES}"} \
     --enable-autoscaling \
     --num-nodes=${_INITIAL_NODES_PER_ZONE} \
     ${_MIN_NODES_PER_ZONE:+"--min-nodes=${_MIN_NODES_PER_ZONE}"} \
     ${_MAX_NODES_PER_ZONE:+"--max-nodes=${_MAX_NODES_PER_ZONE}"} \
     ${USERNAME:+"--username=${USERNAME}"} \
     ${CLUSTER_VERSION:+"--cluster-version=${CLUSTER_VERSION}"} \
     ${MACHINE_TYPE:+"--machine-type=${MACHINE_TYPE}"} \
     ${IMAGE_TYPE:+"--image-type=${IMAGE_TYPE}"} \
     ${DISK_SIZE:+"--disk-size=${DISK_SIZE}"} \
     --network=${NETWORK:-default} \
     --subnetwork=${SUBNETWORK:-default} \
     --scopes=https://www.googleapis.com/auth/compute,https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
     --enable-cloud-logging \
     --enable-cloud-monitoring
