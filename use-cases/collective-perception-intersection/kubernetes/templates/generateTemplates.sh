#!/bin/bash
SCRIPT_PATH=$(readlink -f "$0")
rm -f $(dirname "$SCRIPT_PATH")/../initial_deployment/vehicles/mqtt/*yml
rm -f $(dirname "$SCRIPT_PATH")/../initial_deployment/vehicles/*yml
rm -f $(dirname "$SCRIPT_PATH")/../ros_paramsfiles/mqtt/vehicles/*yml

for i in {00..03}
do 
    export ID=$i
    envsubst '${ID}' < $(dirname "$SCRIPT_PATH")/vehicle_xx_mqtt.yml > $(dirname "$SCRIPT_PATH")/../initial_deployment/vehicles/mqtt/vehicle_${ID}_mqtt.yml
    envsubst '${ID}' < $(dirname "$SCRIPT_PATH")/vehicle_xx_publisher.yml > $(dirname "$SCRIPT_PATH")/../initial_deployment/vehicles/vehicle_${ID}_publisher.yml
    envsubst '${ID}' < $(dirname "$SCRIPT_PATH")/mqtt_params_vehicle_xx.yml > $(dirname "$SCRIPT_PATH")/../ros_paramsfiles/mqtt/vehicles/mqtt_params_vehicle_${ID}.yml
done
# The client for vehicle 00 transmitts the /clock topic
cp $(dirname "$SCRIPT_PATH")/mqtt_params_vehicle_00.yml $(dirname "$SCRIPT_PATH")/../ros_paramsfiles/mqtt/vehicles/mqtt_params_vehicle_00.yml
