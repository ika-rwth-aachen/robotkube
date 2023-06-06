#!/bin/bash
DIR=$(dirname -- $0)
rm -f ../initial_deployment/vehicles/mqtt_clients/*
rm -f ../initial_deployment/vehicles/rosbag_publishers/*
rm -f ../initial_deployment/vehicles/rosmasters/*
rm -f ../initial_deployment/cloud/mqtt_clients/*

for i in {00..14}
do 
    export ID=$i
    envsubst '${ID}' < ${DIR}/vehicles/mqtt-client-vehicle.yaml > ${DIR}/../initial_deployment/vehicles/mqtt_clients/mqtt-client-vehicle-${ID}.yaml
    envsubst '${ID}' < ${DIR}/vehicles/rosbag-publisher.yaml > ${DIR}/../initial_deployment/vehicles/rosbag_publishers/rosbag-publisher-${ID}.yaml
    envsubst '${ID}' < ${DIR}/vehicles/rosmaster.yaml > ${DIR}/../initial_deployment/vehicles/rosmasters/rosmaster-${ID}.yaml
    envsubst '${ID}' < ${DIR}/cloud/mqtt-client-cloud.yaml > ${DIR}/../initial_deployment/cloud/mqtt_clients/mqtt-client-vehicle-${ID}.yaml
done