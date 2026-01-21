#!/bin/bash

echo "Applying DolphinScheduler YAML files..."

echo "1. Applying namespace..."
kubectl apply -f prod-namespace.yaml

echo "2. Applying serviceaccount..."
kubectl apply -f prod-serviceaccount.yaml

echo "3. Applying secret..."
kubectl apply -f prod-secret.yaml

echo "4. Applying configmaps..."
kubectl apply -f prod-configmaps.yaml

echo "5. Applying PVCs..."
kubectl apply -f prod-pvc.yaml

echo "6. Applying services..."
kubectl apply -f prod-services.yaml

echo "7. Applying zookeeper..."
kubectl apply -f prod-cluster-zookeeper.yaml

echo "8. Applying master..."
kubectl apply -f prod-cluster-master.yaml

echo "9. Applying worker..."
kubectl apply -f prod-cluster-worker.yaml

echo "10. Applying api..."
kubectl apply -f prod-cluster-api.yaml

echo "11. Applying alert..."
kubectl apply -f prod-cluster-alert.yaml

echo "Done! Checking pod status..."
kubectl get pods -n bnctl-dolphinscheduler-prod-ns

