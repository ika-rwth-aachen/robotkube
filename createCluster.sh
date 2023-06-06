#!/bin/bash

# Define image names
ROSMASTER_IMAGE="ros:noetic-ros-core"
MQTT_CLIENT_IMAGE="rwthika/robotkube-mqtt-client:2023-06"
EVENT_DETECTOR_IMAGE="rwthika/robotkube-event-detector:2023-06"
MONGO_IMAGE="mongo:6"
APPLICATION_MANAGER_IMAGE="rwthika/robotkube-application-manager:2023-06"
ROSBAG_IMAGE="rwthika/robotkube-demo-rosbag:2023-06"

# Store PIDs of background processes
pids=()

# Delete previous robotkube cluster if it exists
if kind get clusters | grep -q "robotkube"; then kind delete cluster --name robotkube; fi

# Create robotkube cluster using config file
kind create cluster --config=robotkube-kind-cluster.yaml --name robotkube

# Function to pull and load an image
pull_and_load_image() {
    local image_name="$1"
    
    if docker pull --quiet "$image_name"; then
        kind load docker-image "$image_name" --name robotkube &
        pids+=($!)
    else
        echo "Error: Failed to pull or access the $image_name image."
        kill "${pids[@]}" >/dev/null 2>&1
        exit 1
    fi
}

# Pull and load images into cluster
pull_and_load_image "$ROSMASTER_IMAGE"
pull_and_load_image "$MQTT_CLIENT_IMAGE"
pull_and_load_image "$EVENT_DETECTOR_IMAGE"
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
