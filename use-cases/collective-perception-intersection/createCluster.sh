#!/bin/bash

REGISTRY_PORT=41670

# Delete previous robotkube cluster if it exists
if k3d cluster list | grep -q "robotkube"; then k3d cluster delete robotkube; fi

SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
cp /etc/machine-id $SCRIPT_DIR/data/machine-id/ -f

# Create robotkube cluster using config file
cat <<EOL > $SCRIPT_DIR/robotkube-k3d-cluster.yml
kind: Simple
apiVersion: k3d.io/v1alpha5
servers: 1
agents: 6
volumes:
  - volume: $SCRIPT_DIR/data/machine-id/machine-id:/etc/machine-id
options:
  k3s:
    nodeLabels:
      - label: node_id=cloud
        nodeFilters:
          - server:0
      - label: node_id=edge
        nodeFilters:
          - agent:0
      - label: node_id=station00
        nodeFilters:
          - agent:1
      - label: node_id=vehicle00
        nodeFilters:
          - agent:2
      - label: node_id=vehicle01
        nodeFilters:
          - agent:3
      - label: node_id=vehicle02
        nodeFilters:
          - agent:4
      - label: node_id=vehicle03
        nodeFilters:
          - agent:5
EOL
# Create k3d cluster and allow more memory usage per node than default
k3d cluster create robotkube --config=$SCRIPT_DIR/robotkube-k3d-cluster.yml --registry-use k3d-robotkube-registry.localhost:$REGISTRY_PORT \
  --k3s-arg "--kubelet-arg=eviction-hard=memory.available<200Mi,nodefs.available<5%,imagefs.available<5%@all" \
  --k3s-arg "--kubelet-arg=eviction-soft=memory.available<500Mi,nodefs.available<10%,imagefs.available<10%@all" \
  --k3s-arg "--kubelet-arg=eviction-soft-grace-period=memory.available=1m,nodefs.available=1m,imagefs.available=1m@all" \
  --volume $SCRIPT_DIR/kubernetes/:/kubelet_config/ \
  --k3s-arg "--kubelet-arg=config=/kubelet_config/kubelet_config.yml@all" \

# Create Custom Resource Definitions
echo "Creating Custom Resource Definitions ..."
kubectl create -f $SCRIPT_DIR/kubernetes/application_manager/custom-operators/mqtt-connection/custom-resource-definition/
kubectl create -f $SCRIPT_DIR/kubernetes/application_manager/custom-operators/object-detection/custom-resource-definition/
kubectl create -f $SCRIPT_DIR/kubernetes/application_manager/custom-operators/object-fusion/custom-resource-definition/
echo "CRDs have been created."

# Pull images from k3d image registry to all nodes
python3 $SCRIPT_DIR/../../utils/prepullImages.py --registry_name k3d-robotkube-registry.localhost --port $REGISTRY_PORT --yaml_file_path $SCRIPT_DIR/imagesPerNode.yml
kubectl get pods --all-namespaces | grep "node-debugger-k3d-robotkube" | awk '{print $2 " -n " $1}' | xargs -L1 kubectl delete pod 1>/dev/null
python3 $SCRIPT_DIR/../../utils/prepullImagesCheck.py --registry_name k3d-robotkube-registry.localhost --port $REGISTRY_PORT --yaml_file_path $SCRIPT_DIR/imagesPerNode.yml

# Print message when all processes have finished
echo "All processes have finished. The RobotKube Kubernetes cluster has successfully been prepared."
