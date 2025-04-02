#!/bin/bash

SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

echo "Resetting RobotKube cluster resources ..."
kubectl delete deployments,services,configmaps,clusterrolebindings,clusterroles,persistentvolumes,persistentvolumeclaims -l tag=robotkube 1>/dev/null
kubectl delete deployments,services,configmaps -l label=am 1>/dev/null
helm list -f appmanager --short | while read -r release; do
    helm uninstall "$release" 1>/dev/null
done
echo "RobotKube cluster has been reset."

echo "Starting initial Services ..."
# Create all Services of the initial deployment
find $SCRIPT_DIR/kubernetes/initial_deployment/cloud -maxdepth 1 -type f -name "*.yaml" -exec awk 'BEGIN{RS="\n\n";ORS="\n---\n"} /apiVersion: v1/ && /kind: Service/' {} + | kubectl apply -f - 1>/dev/null 2>&1
find $SCRIPT_DIR/kubernetes/initial_deployment/vehicles -maxdepth 1 -type f -name "*.yaml" -exec awk 'BEGIN{RS="\n\n";ORS="\n---\n"} /apiVersion: v1/ && /kind: Service/' {} + | kubectl apply -f - 1>/dev/null 2>&1
find $SCRIPT_DIR/kubernetes/initial_deployment/cloud/mqtt -type f -name "*.yaml" -exec awk 'BEGIN{RS="\n\n";ORS="\n---\n"} /apiVersion: v1/ && /kind: Service/' {} + | kubectl apply -f - 1>/dev/null 2>&1
find $SCRIPT_DIR/kubernetes/initial_deployment/vehicles/mqtt -type f -name "*.yaml" -exec awk 'BEGIN{RS="\n\n";ORS="\n---\n"} /apiVersion: v1/ && /kind: Service/' {} + | kubectl apply -f - 1>/dev/null 2>&1
echo "Initial services have been started."

# Create K8s Roles
echo "Creating cluster roles ..."
kubectl create -f $SCRIPT_DIR/kubernetes/roles 1>/dev/null
echo "Cluster Roles have been created."

# create configmaps
echo "Creating configmaps ..."
kubectl create configmap mqtt-params-vehicles --from-file=$SCRIPT_DIR/kubernetes/ros_paramsfiles/mqtt/vehicles/mqtt_params_vehicle_00.yaml \
                                              --from-file=$SCRIPT_DIR/kubernetes/ros_paramsfiles/mqtt/vehicles/mqtt_params_vehicle_01.yaml \
                                              --from-file=$SCRIPT_DIR/kubernetes/ros_paramsfiles/mqtt/vehicles/mqtt_params_vehicle_02.yaml \
                                              --from-file=$SCRIPT_DIR/kubernetes/ros_paramsfiles/mqtt/vehicles/mqtt_params_vehicle_03.yaml \
                                              --from-file=$SCRIPT_DIR/kubernetes/ros_paramsfiles/mqtt/vehicles/mqtt_params_vehicle_05.yaml \
                                              --from-file=$SCRIPT_DIR/kubernetes/ros_paramsfiles/mqtt/vehicles/mqtt_params_vehicle_06.yaml \
                                              --from-file=$SCRIPT_DIR/kubernetes/ros_paramsfiles/mqtt/vehicles/mqtt_params_vehicle_04.yaml \
                                              --from-file=$SCRIPT_DIR/kubernetes/ros_paramsfiles/mqtt/vehicles/mqtt_params_vehicle_07.yaml \
                                              --from-file=$SCRIPT_DIR/kubernetes/ros_paramsfiles/mqtt/vehicles/mqtt_params_vehicle_08.yaml \
                                              --from-file=$SCRIPT_DIR/kubernetes/ros_paramsfiles/mqtt/vehicles/mqtt_params_vehicle_09.yaml \
                                              --from-file=$SCRIPT_DIR/kubernetes/ros_paramsfiles/mqtt/vehicles/mqtt_params_vehicle_10.yaml \
                                              --from-file=$SCRIPT_DIR/kubernetes/ros_paramsfiles/mqtt/vehicles/mqtt_params_vehicle_11.yaml \
                                              --from-file=$SCRIPT_DIR/kubernetes/ros_paramsfiles/mqtt/vehicles/mqtt_params_vehicle_12.yaml \
                                              --from-file=$SCRIPT_DIR/kubernetes/ros_paramsfiles/mqtt/vehicles/mqtt_params_vehicle_13.yaml \
                                              --from-file=$SCRIPT_DIR/kubernetes/ros_paramsfiles/mqtt/vehicles/mqtt_params_vehicle_14.yaml \
                                              --from-file=$SCRIPT_DIR/kubernetes/ros_launchfiles/standalone_mqtt_client_vehicle.launch.ros2.xml \
                                              -o yaml --dry-run=client | sed 's/^metadata:/metadata:\n  labels:\n    tag: robotkube/'| kubectl apply -f - 1>/dev/null
kubectl create configmap mqtt-params-cloud --from-file=$SCRIPT_DIR/kubernetes/ros_paramsfiles/mqtt/cloud/mqtt_params_cloud.yaml \
                                           --from-file=$SCRIPT_DIR/kubernetes/ros_launchfiles/standalone_mqtt_client_cloud.launch.ros2.xml \
                                           -o yaml --dry-run=client | sed 's/^metadata:/metadata:\n  labels:\n    tag: robotkube/' | kubectl apply -f - 1>/dev/null
kubectl create configmap event-detector-operator-params --from-file=$SCRIPT_DIR/kubernetes/ros_paramsfiles/event_detector_operator.params.yaml -o yaml --dry-run=client | sed 's/^metadata:/metadata:\n  labels:\n    tag: robotkube/' | kubectl apply -f - 1>/dev/null
kubectl create configmap application-manager-params --from-file=$SCRIPT_DIR/kubernetes/ros_paramsfiles/application_manager.params.yaml -o yaml --dry-run=client | sed 's/^metadata:/metadata:\n  labels:\n    tag: robotkube/' | kubectl apply -f - 1>/dev/null
echo "Configmaps have been created."

# Create K8S Persistent Volumes
echo "Creating persistent volumes ..."
kubectl create -f $SCRIPT_DIR/kubernetes/volumes/ 1>/dev/null
echo "Persistent volumes have been created."

echo "Requesting initial Deployments ..."
# Create all Deployments of the initial deployment
find $SCRIPT_DIR/kubernetes/initial_deployment/cloud -maxdepth 1 -type f -name "*.yaml" -exec awk 'BEGIN{RS="\n\n";ORS="\n---\n"} /apiVersion: apps\/v1/ && /kind: Deployment/' {} + | kubectl apply -f - 1>/dev/null
find $SCRIPT_DIR/kubernetes/initial_deployment/vehicles -maxdepth 1 -type f -name "*.yaml" -exec awk 'BEGIN{RS="\n\n";ORS="\n---\n"} /apiVersion: apps\/v1/ && /kind: Deployment/' {} + | kubectl apply -f - 1>/dev/null
find $SCRIPT_DIR/kubernetes/initial_deployment/cloud/mqtt -type f -name "*.yaml" -exec awk 'BEGIN{RS="\n\n";ORS="\n---\n"} /apiVersion: apps\/v1/ && /kind: Deployment/' {} + | kubectl apply -f - 1>/dev/null
find $SCRIPT_DIR/kubernetes/initial_deployment/vehicles/mqtt -type f -name "*.yaml" -exec awk 'BEGIN{RS="\n\n";ORS="\n---\n"} /apiVersion: apps\/v1/ && /kind: Deployment/' {} + | kubectl apply -f - 1>/dev/null
echo "Initial deployments have been requested."

# Calculate how many pods there should be based on the number of requested deployments.
expected_pod_count=$(find $SCRIPT_DIR/kubernetes/initial_deployment/cloud -maxdepth 1 -type f -name "*.yaml" -exec awk 'BEGIN{RS="\n\n";ORS="\n---\n"} /apiVersion: apps\/v1/ && /kind: Deployment/' {} + | grep -c '^---$')
expected_pod_count=$((expected_pod_count + $(find $SCRIPT_DIR/kubernetes/initial_deployment/vehicles -maxdepth 1 -type f -name "*.yaml" -exec awk 'BEGIN{RS="\n\n";ORS="\n---\n"} /apiVersion: apps\/v1/ && /kind: Deployment/' {} + | grep -c '^---$')))
expected_pod_count=$((expected_pod_count + $(find $SCRIPT_DIR/kubernetes/initial_deployment/cloud/mqtt -type f -name "*.yaml" -exec awk 'BEGIN{RS="\n\n";ORS="\n---\n"} /apiVersion: apps\/v1/ && /kind: Deployment/' {} + | grep -c '^---$')))
expected_pod_count=$((expected_pod_count + $(find $SCRIPT_DIR/kubernetes/initial_deployment/vehicles/mqtt -type f -name "*.yaml" -exec awk 'BEGIN{RS="\n\n";ORS="\n---\n"} /apiVersion: apps\/v1/ && /kind: Deployment/' {} + | grep -c '^---$')))

# Wait until all the rosbag-pods are running and then start the bagfiles
echo "Waiting for all $expected_pod_count pods to be created ..."

# Function to check if all pods exist
function all_pods_exist() {
    local pod_count=$(kubectl get pods --no-headers | wc -l)

    echo -ne "Current number of created pods: $pod_count\r"

    if [[ $pod_count -eq $expected_pod_count ]]; then
        echo "Current number of created pods: $pod_count"
        return 0  # All pods exist, return success (0)
    else
        return 1  # Some pods are missing, return failure (non-zero)
    fi
}

while ! all_pods_exist; do
    sleep 0.1
done

echo "Waiting for all $expected_pod_count pods to start running ..."

pod_names=$(kubectl get pods --no-headers | awk '{print $1}')

# Function to check if all pods are running
function all_pods_running() {
    local all_running=0
    local running_count=0

    for pod_name in $pod_names; do
        # Get the pod status
        pod_status=$(kubectl get pod $pod_name -o json | jq -r '.status.phase')

        # Check if the pod is running
        if [[ "$pod_status" == "Running" ]]; then
            ((running_count++))
        else
            all_running=1
        fi
    done

    echo -ne "Currently running pods: $running_count\r"
    return $all_running
}

# Wait until all pods are successfully running for at least some time
waiting_duration_in_seconds=5
while true; do
    if all_pods_running; then
        # Wait for 2 seconds
        echo "All pods are running, waiting $waiting_duration_in_seconds seconds and checking again"
        sleep $waiting_duration_in_seconds

        # Check again after the delay
        if all_pods_running; then
            echo "All pods are running, starting data transmission."
            break
        fi
    fi
    sleep 0.1
done

# Get the names of all pods containing "vehicle-publisher"
pod_names_rosbag=$(kubectl get pods | grep vehicle-.*-publisher | awk '{print $1}')

# All pods are running, print their names and the current date and do ros2 bag play
for pod_name in $pod_names_rosbag; do
    # Start the rosbag
    id=$(echo $pod_name | awk -F '-' '{print $2}')
    kubectl exec $pod_name -c rosbag-play  -- bash -c "echo $pod_name $(date +'%T.%3N') ; . /opt/ros/humble/setup.bash ; ros2 bag play -l -r 1 --start-offset 50 /tmp/bagfile_split${id} >/dev/null 2>&1 &  " >/dev/null & 
done

wait

echo "Initial Deployment is complete."