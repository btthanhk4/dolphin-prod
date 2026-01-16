# Hướng dẫn Apply DolphinScheduler lên UAT

## Các file cần apply (theo thứ tự):

1. **uat-serviceaccount.yaml** - ServiceAccount cho các pods
2. **uat-secret.yaml** - Secrets (database password, etc.)
3. **uat-cm.yaml** - ConfigMaps (cấu hình chung)
4. **uat-pvc.yaml** - PersistentVolumeClaims (storage cho alert và spark-code-sync)
5. **uat-services.yaml** - Services (API, Alert, Master, Worker, Zookeeper)
6. **uat-cluster-zookeeper.yaml** - Zookeeper StatefulSet
7. **uat-cluster-master.yaml** - Master StatefulSet
8. **uat-cluster-worker.yaml** - Worker StatefulSet
9. **uat-cluster-api.yaml** - API Deployment
10. **uat-cluster-alert.yaml** - Alert Deployment

## Cách apply:

### Option 1: Sử dụng script tự động
```bash
# Xóa namespace và tạo lại từ đầu
kubectl delete namespace bnctl-dolphinscheduler-uat-ns
kubectl create namespace bnctl-dolphinscheduler-uat-ns

# Apply tất cả các file
./apply-uat.sh update
```

### Option 2: Apply thủ công từng file
```bash
# Tạo namespace
kubectl create namespace bnctl-dolphinscheduler-uat-ns

# Apply theo thứ tự
kubectl apply -f uat-serviceaccount.yaml
kubectl apply -f uat-secret.yaml
kubectl apply -f uat-cm.yaml
kubectl apply -f uat-pvc.yaml
kubectl apply -f uat-services.yaml
kubectl apply -f uat-cluster-zookeeper.yaml
sleep 10  # Đợi zookeeper khởi động
kubectl apply -f uat-cluster-master.yaml
kubectl apply -f uat-cluster-worker.yaml
kubectl apply -f uat-cluster-api.yaml
kubectl apply -f uat-cluster-alert.yaml
```

## Kiểm tra sau khi apply:

```bash
# Kiểm tra pods
kubectl get pods -n bnctl-dolphinscheduler-uat-ns

# Kiểm tra services
kubectl get svc -n bnctl-dolphinscheduler-uat-ns

# Kiểm tra PVCs
kubectl get pvc -n bnctl-dolphinscheduler-uat-ns

# Xem logs nếu có lỗi
kubectl logs -n bnctl-dolphinscheduler-uat-ns <pod-name>
```

## Lưu ý:

- **PVCs**: Các PVCs sẽ được tạo tự động khi apply `uat-pvc.yaml`
- **StatefulSets**: Master và Worker sử dụng volumeClaimTemplates nên sẽ tự động tạo PVCs khi pods được tạo
- **Services**: Tất cả services cần thiết đã được định nghĩa trong `uat-services.yaml`
- **ServiceAccount**: Cần tạo trước khi các pods được tạo

