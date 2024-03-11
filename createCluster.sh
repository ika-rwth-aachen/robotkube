#!/bin/bash

# Define image names
MQTT_CLIENT_IMAGE="rwthika/robotkube-mqtt-client:2024-03"
EVENT_DETECTOR_RECORDING_PLUGIN_IMAGE="rwthika/robotkube-event-detector-recording:2024-03"
EVENT_DETECTOR_OPERATOR_PLUGIN_IMAGE="rwthika/robotkube-event-detector-operator:2024-03"
MONGO_IMAGE="mongo:6"
APPLICATION_MANAGER_IMAGE="rwthika/robotkube-application-manager:2024-03"
ROSBAG_IMAGE="rwthika/robotkube-demo-rosbag:2024-03"

# Store PIDs of background processes
pids=()

# Delete previous robotkube cluster if it exists
if k3d cluster list | grep -q "robotkube"; then k3d cluster delete robotkube; fi

# Create robotkube cluster using config file
SCRIPT_PATH=$(readlink -f "$0")
cat <<EOL > robotkube-k3d-cluster.yaml
kind: Simple
apiVersion: k3d.io/v1alpha5
volumes:
  - volume: $(dirname "$SCRIPT_PATH")/data/db:/data/db
  - volume: $(dirname "$SCRIPT_PATH")/data/large_data:/data/large_data
EOL
k3d cluster create robotkube --config=robotkube-k3d-cluster.yaml

# Function to pull and load an image
pull_and_load_image() {
    local image_name="$1"

    if docker pull --quiet "$image_name"; then
        k3d image import "$image_name" --cluster robotkube
        pids+=($!)
    else
        echo "Error: Failed to pull or access the $image_name image."
        kill "${pids[@]}" >/dev/null 2>&1
        exit 1
    fi
}

# Pull and load images into cluster
pull_and_load_image "$MQTT_CLIENT_IMAGE"
pull_and_load_image "$EVENT_DETECTOR_RECORDING_PLUGIN_IMAGE"
pull_and_load_image "$EVENT_DETECTOR_OPERATOR_PLUGIN_IMAGE"
pull_and_load_image "$MONGO_IMAGE"
pull_and_load_image "$APPLICATION_MANAGER_IMAGE"
pull_and_load_image "$ROSBAG_IMAGE"

# Wait for all background processes to finish
echo "Waiting for all background processes to finish ..."
for pid in "${pids[@]}"; do
    wait "$pid"
done

# Print message when all processes have finished
echo "All processes have finished. The RobotKube Kubernetes cluster has successfully been prepared."
