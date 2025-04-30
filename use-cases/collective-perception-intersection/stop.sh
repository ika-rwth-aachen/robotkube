#!/bin/bash

echo "Stop Kubernetes ressources ..."
kubectl delete deployments,services,configmaps,clusterrolebindings,clusterroles,roles,rolebindings,persistentvolumes,persistentvolumeclaims,serviceaccounts -l tag=robotkube 1>/dev/null
kubectl delete deployments,services,configmaps -l tag=application-manager 1>/dev/null
kubectl get mqttconnections.ika.rwth-aachen.de -o json | jq '.items[] | .metadata.name' | xargs -I {} kubectl patch mqttconnections.ika.rwth-aachen.de {} --type=merge -p '{"metadata":{"finalizers":[]}}' 1>/dev/null 2>/dev/null
kubectl get objectdetections.ika.rwth-aachen.de -o json | jq '.items[] | .metadata.name' | xargs -I {} kubectl patch objectdetections.ika.rwth-aachen.de {} --type=merge -p '{"metadata":{"finalizers":[]}}' 1>/dev/null 2>/dev/null
kubectl get objectfusions.ika.rwth-aachen.de -o json | jq '.items[] | .metadata.name' | xargs -I {} kubectl patch objectfusions.ika.rwth-aachen.de {} --type=merge -p '{"metadata":{"finalizers":[]}}' 1>/dev/null 2>/dev/null
kubectl delete objectdetections.ika.rwth-aachen.de,objectfusions.ika.rwth-aachen.de,mqttconnections.ika.rwth-aachen.de -l tag=application-manager 1>/dev/null 2>/dev/null
echo "Uninstall Helm releases ..."
if [ -n "$(helm ls --short)" ]; then
    helm list --short | xargs -n1 helm delete
fi