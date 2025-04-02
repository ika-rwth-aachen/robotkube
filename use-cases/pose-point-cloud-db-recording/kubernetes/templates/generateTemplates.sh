#!/bin/bash
DIR=$(dirname -- $0)
rm -f ${DIR}/../initial_deployment/vehicles/mqtt/*yaml
rm -f ${DIR}/../initial_deployment/vehicles/*yaml
rm -f ${DIR}/../ros_paramsfiles/mqtt/vehicles/*

for i in {00..14}
do 
    export ID=$i
    envsubst '${ID}' < ${DIR}/vehicles/vehicle_publisher.yaml > ${DIR}/../initial_deployment/vehicles/vehicle_${ID}_publisher.yaml
    envsubst '${ID}' < ${DIR}/vehicles/mqtt/vehicle_mqtt.yaml > ${DIR}/../initial_deployment/vehicles/mqtt/vehicle_${ID}_mqtt.yaml
    envsubst '${ID}' < ${DIR}/vehicles/mqtt/mqtt_params_vehicle.yaml > ${DIR}/../ros_paramsfiles/mqtt/vehicles/mqtt_params_vehicle_${ID}.yaml
done
# The client for vehicle 00 transmitts the /clock topic
cp ${DIR}/vehicles/mqtt/mqtt_params_vehicle_00.yaml ${DIR}/../ros_paramsfiles/mqtt/vehicles/mqtt_params_vehicle_00.yaml
