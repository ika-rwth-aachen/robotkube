#!/bin/bash

echo "Resetting RobotKube cluster resources ..."
kubectl delete deployments,services,configmaps,rolebindings,clusterroles,persistentvolumes,persistentvolumeclaims -l app=robotkube 1>/dev/null
echo "RobotKube cluster has been reset."

echo "Starting initial Services ..."
# Create all Services of the initial deployment
find kubernetes/initial_deployment -type f -name "*.yaml" -exec awk 'BEGIN{RS="\n\n";ORS="\n---\n"} /apiVersion: v1/ && /kind: Service/' {} + | kubectl apply -f - 1>/dev/null
echo "Initial services have been started."

# Create K8S Roles
echo "Creating cluster roles ..."
kubectl create -f kubernetes/initial_deployment/roles 1>/dev/null
echo "Cluster Roles have been created."

# create configmaps
echo "Creating configmaps ..."
kubectl create configmap mqtt-params-vehicle-to-ed-k8s-source --from-file=kubernetes/ros_paramsfiles/mqtt_params_vehicle_to_ed_k8s_source.yaml --from-file=kubernetes/ros_launchfiles/standalone_mqtt_client.launch -o yaml --dry-run=client | sed 's/^metadata:/metadata:\n  labels:\n    app: robotkube/'| kubectl apply -f - 1>/dev/null
kubectl create configmap mqtt-params-vehicle-to-ed-k8s-target --from-file=kubernetes/ros_paramsfiles/mqtt_params_vehicle_to_ed_k8s_target.yaml --from-file=kubernetes/ros_launchfiles/standalone_mqtt_client.launch -o yaml --dry-run=client | sed 's/^metadata:/metadata:\n  labels:\n    app: robotkube/' | kubectl apply -f - 1>/dev/null
kubectl create configmap ed-params-k8s-rule --from-file=kubernetes/ros_paramsfiles/ed_params_k8s_rule.yaml --from-file=kubernetes/ros_launchfiles/standalone_ed_k8s.launch -o yaml --dry-run=client | sed 's/^metadata:/metadata:\n  labels:\n    app: robotkube/' | kubectl apply -f - 1>/dev/null
echo "Configmaps have been created."

# Create K8S Persistent Volumes
echo "Creating persistent volumes ..."
kubectl create -f kubernetes/volumes/ 1>/dev/null
echo "Persistent volumes have been created."

echo "Requesting initial Deployments ..."
# Create all Deployments of the initial deployment
kubectl apply -f kubernetes/initial_deployment/vehicles/rosmasters 1>/dev/null # masters first
kubectl apply -f kubernetes/initial_deployment/cloud/rosmaster.yaml 1>/dev/null # masters first
sleep 15
find kubernetes/initial_deployment -type f -name "*.yaml" -exec awk 'BEGIN{RS="\n\n";ORS="\n---\n"} /apiVersion: apps\/v1/ && /kind: Deployment/' {} + | kubectl apply -f - 1>/dev/null
echo "Initial deployments have been requested."

# Calculate how many pods there should be based on the number of requested deployments.
expected_pod_count=$(find kubernetes/initial_deployment -type f -name "*.yaml" -exec awk 'BEGIN{RS="\n\n";ORS="\n---\n"} /apiVersion: apps\/v1/ && /kind: Deployment/' {} + | grep -c '^---$')

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

# Wait until all "rosbag-vehicle" pods exist
while ! all_pods_exist; do
    sleep 0.1
done

echo "Waiting for all $expected_pod_count pods to start running ..."
# Get the names of all pods containing "rosbag-vehicle"
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


pod_names_rosbag=$(kubectl get pods | grep rosbag-vehicle | awk '{print $1}')

# All pods are running, print their names and the current date and do rosbag play
for pod_name in $pod_names_rosbag; do
    # Start the rosbag
    id=$(echo $pod_name | awk -F '-' '{print $3}')
    kubectl exec $pod_name  -- bash -c "echo $pod_name $(date +'%T.%3N') ; . /opt/ros/noetic/setup.bash ; rosbag play -l -r 1 -s 50 /tmp/bagfile_split${id}.bag >/dev/null 2>&1 &  " >/dev/null & 
done

wait

echo "Initial Deployment is complete."