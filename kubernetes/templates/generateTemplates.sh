#!/bin/bash
DIR=$(dirname -- $0)
rm -f ../initial_deployment/vehicles/*
rm -f ../initial_deployment/cloud/cloud_operator.yaml
rm -f ../ros_paramsfiles/mqtt_vehicle_source/*
rm -f ../ros_paramsfiles/mqtt_vehicle_target/*

for i in {00..14}
do 
    export ID=$i
    envsubst '${ID}' < ${DIR}/vehicles/vehicle-publisher.yaml > ${DIR}/../initial_deployment/vehicles/vehicle-publisher-${ID}.yaml
    envsubst '${ID}' < ${DIR}/vehicles/mqtt_params_vehicle_to_ed_k8s_source.yaml > ${DIR}/../ros_paramsfiles/mqtt_vehicle_source/mqtt_params_vehicle-${ID}_to_ed_k8s_source.yaml
    envsubst '${ID}' < ${DIR}/vehicles/mqtt_params_vehicle_to_ed_k8s_target.yaml > ${DIR}/../ros_paramsfiles/mqtt_vehicle_target/mqtt_params_vehicle-${ID}_to_ed_k8s_target.yaml
done

## Dynamically add MQTT client containers for each vehicle to the deployment file cloud_operator.yaml
# Initialize the dynamic containers string
DYNAMIC_CONTAINERS=""
# Loop to generate dynamic container entries
for i in {00..14}
do
  # Load the dynamic container entry template from a file
  DYNAMIC_CONTAINER_ENTRY=$(cat ${DIR}/cloud/mqtt_client_container_template.txt)

  # Replace placeholders with actual values
  DYNAMIC_CONTAINER_ENTRY="${DYNAMIC_CONTAINER_ENTRY//\{\{CONTAINER_NAME\}\}/mqtt-client-vehicle-${i}-cloud}"
  DYNAMIC_CONTAINER_ENTRY="${DYNAMIC_CONTAINER_ENTRY//\{\{CONTAINER_INDEX\}\}/$i}"  

  # Append the dynamic container entry to the DYNAMIC_CONTAINERS string
  DYNAMIC_CONTAINERS="${DYNAMIC_CONTAINERS}${DYNAMIC_CONTAINER_ENTRY}"$'\n'
done

# Replace the placeholder in the YAML file with the dynamic containers
awk -v dynamic_containers="$DYNAMIC_CONTAINERS" '/{{DYNAMIC_CONTAINERS}}/ {sub("{{DYNAMIC_CONTAINERS}}", dynamic_containers)}1' ${DIR}/cloud/cloud_operator.yaml > ${DIR}/../initial_deployment/cloud/cloud_operator.yaml
