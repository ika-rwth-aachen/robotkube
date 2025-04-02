#!/bin/bash

# Define image names
APPLICATION_MANAGER_IMAGE="rwthika/robotkube-application-manager:2025-03"
ECLIPSE_MOSQUITTO_IMAGE="eclipse-mosquitto:latest"
EVENT_DETECTOR_DB_RECORDING_PLUGIN_IMAGE="rwthika/robotkube-event-detector-recording:2025-03"
EVENT_DETECTOR_OPERATOR_PLUGIN_IMAGE="rwthika/robotkube-event-detector-operator:2025-03"
MQTT_CLIENT_IMAGE="rwthika/robotkube-mqtt-client:2025-03"
MONGO_IMAGE="mongo:6"
ROSBAG_IMAGE="rwthika/robotkube-demo-rosbag:2024-03"

# Define target image names used in the registry
declare -A TARGET_IMAGE_NAMES=(
    ["$APPLICATION_MANAGER_IMAGE"]="application_manager:latest"
    ["$ECLIPSE_MOSQUITTO_IMAGE"]="eclipse-mosquitto:latest"
    ["$EVENT_DETECTOR_DB_RECORDING_PLUGIN_IMAGE"]="event_detector_db_recording:latest"
    ["$EVENT_DETECTOR_OPERATOR_PLUGIN_IMAGE"]="event_detector_operator:latest"
    ["$MQTT_CLIENT_IMAGE"]="mqtt_client:latest"
    ["$MONGO_IMAGE"]="mongo:6"
    ["$ROSBAG_IMAGE"]="robotkube:ros2_bag_files"
)

# Define registry information
REGISTRY_NAME="robotkube-registry.localhost"
PORT=41673

# Store PIDs of background processes
pids=()

# Check if the registry already exists
if k3d registry list | grep -q "$REGISTRY_NAME"; then
    read -p "Registry '$REGISTRY_NAME' already exists. Do you want to delete it and recreate it? It will be reused otherwise. (y/n, default: n): " response
    response=${response:-n}  # Default to 'n' if no input is provided
    if [[ "$response" == "y" || "$response" == "Y" ]]; then
        echo "Deleting existing registry '$REGISTRY_NAME'..."
        k3d registry delete "$REGISTRY_NAME" >/dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to delete the existing registry. Exiting."
            exit 1
        fi
        echo "Creating a new registry..."
        k3d registry create "$REGISTRY_NAME" --port "$PORT"
    else
        echo "Reusing the existing registry."
    fi
else
    echo "Creating a new registry..."
    k3d registry create "$REGISTRY_NAME" --port "$PORT"
fi

# Tag and push images to the registry
tag_and_push_image_to_registry() {
    local image_name="$1"
    local image_name_registry="$REGISTRY_NAME:$PORT/${TARGET_IMAGE_NAMES[$image_name]}"

    # Pull the image
    echo "Pulling image $image_name"
    if docker pull --quiet "$image_name"; then
        # Tag and push the image to the registry
        echo "Pushing image $image_name_registry to k3d registry.."
        docker tag "$image_name" "$image_name_registry"
        docker push "$image_name_registry" &
        pids+=($!)
    else
        echo "Error: Failed to pull or access the $image_name image."
        kill "${pids[@]}" >/dev/null 2>&1
        exit 1
    fi
}

# Tag and push images to registry
tag_and_push_image_to_registry "$MQTT_CLIENT_IMAGE"
tag_and_push_image_to_registry "$ECLIPSE_MOSQUITTO_IMAGE"
tag_and_push_image_to_registry "$EVENT_DETECTOR_DB_RECORDING_PLUGIN_IMAGE"
tag_and_push_image_to_registry "$EVENT_DETECTOR_OPERATOR_PLUGIN_IMAGE"
tag_and_push_image_to_registry "$MONGO_IMAGE"
tag_and_push_image_to_registry "$APPLICATION_MANAGER_IMAGE"
tag_and_push_image_to_registry "$ROSBAG_IMAGE"

# Wait for all background processes to finish
echo "Waiting for all background processes to finish ..."
for pid in "${pids[@]}"; do
    wait "$pid"
done

# Check if the images are in the registry
echo "The following images were pushed to the k3d registry: $(curl -X GET http://localhost:"$PORT"/v2/_catalog)"
