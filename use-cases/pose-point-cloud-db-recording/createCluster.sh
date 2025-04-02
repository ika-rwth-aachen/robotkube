#!/bin/bash

# Delete previous robotkube cluster if it exists
if k3d cluster list | grep -q "robotkube"; then k3d cluster delete robotkube; fi

# Minimum required disk space in GB
REQUIRED=400

# Get available disk space on root (/) in GB (integer, no unit)
AVAILABLE=$(df -B1G / | awk 'NR==2 {sub(/G/,"",$4); print $4}')

# Exit if available space is below requirement
if (( AVAILABLE < REQUIRED )); then
  echo "Not enough disk space available. Required: ${REQUIRED} GB, but only ${AVAILABLE} GB available."
  exit 1
fi

# Create robotkube cluster using config file
SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
cat <<EOL > robotkube-k3d-cluster.yaml
kind: Simple
apiVersion: k3d.io/v1alpha5
servers: 1
agents: 15
volumes:
  - volume: $SCRIPT_DIR/data/db:/data/db
  - volume: $SCRIPT_DIR/data/large_data:/data/large_data
options:
  k3s:
    nodeLabels:
      - label: node_id=cloud
        nodeFilters:
          - server:0
      - label: node_id=vehicle_00
        nodeFilters:
          - agent:0
      - label: node_id=vehicle_01
        nodeFilters:
          - agent:1
      - label: node_id=vehicle_02
        nodeFilters:
          - agent:2
      - label: node_id=vehicle_03
        nodeFilters:
          - agent:3
      - label: node_id=vehicle_04
        nodeFilters:
          - agent:4
      - label: node_id=vehicle_05
        nodeFilters:
          - agent:5
      - label: node_id=vehicle_06
        nodeFilters:
          - agent:6
      - label: node_id=vehicle_07
        nodeFilters:
          - agent:7
      - label: node_id=vehicle_08
        nodeFilters:
          - agent:8
      - label: node_id=vehicle_09
        nodeFilters:
          - agent:9
      - label: node_id=vehicle_10
        nodeFilters:
          - agent:10
      - label: node_id=vehicle_11
        nodeFilters:
          - agent:11
      - label: node_id=vehicle_12
        nodeFilters:
          - agent:12
      - label: node_id=vehicle_13
        nodeFilters:
          - agent:13
      - label: node_id=vehicle_14
        nodeFilters:
          - agent:14
EOL
# Create k3d cluster and allow more memory usage per node than default
k3d cluster create robotkube --config=robotkube-k3d-cluster.yaml --registry-use k3d-robotkube-registry.localhost:41673 \
  --k3s-arg "--kubelet-arg=eviction-hard=memory.available<200Mi,nodefs.available<5%,imagefs.available<5%@all" \
  --k3s-arg "--kubelet-arg=eviction-soft=memory.available<500Mi,nodefs.available<10%,imagefs.available<10%@all" \
  --k3s-arg "--kubelet-arg=eviction-soft-grace-period=memory.available=1m,nodefs.available=1m,imagefs.available=1m@all"

# Pull images from k3d image registry to all nodes
python3 $SCRIPT_DIR/../../utils/prepullImages.py --registry_name k3d-robotkube-registry.localhost --port 41673 --yaml_file_path $SCRIPT_DIR/imagesPerNode.yml
kubectl get pods --all-namespaces | grep "node-debugger-k3d-robotkube" | awk '{print $2 " -n " $1}' | xargs -L1 kubectl delete pod 1>/dev/null
python3 $SCRIPT_DIR/../../utils/prepullImagesCheck.py --registry_name k3d-robotkube-registry.localhost --port 41673 --yaml_file_path $SCRIPT_DIR/imagesPerNode.yml

# Print message when all processes have finished
echo "All processes have finished. The RobotKube Kubernetes cluster has successfully been prepared."
