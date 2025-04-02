#!/bin/bash

echo "Stop Kubernetes ressources ..."
kubectl delete deployments,services,configmaps,clusterrolebindings,clusterroles,persistentvolumes,persistentvolumeclaims -l tag=robotkube 1>/dev/null
kubectl delete deployments,services,configmaps -l label=am 1>/dev/null
echo "Uninstall Helm releases ..."
helm list -f appmanager --short | while read -r release; do
    helm uninstall "$release" 1>/dev/null
done