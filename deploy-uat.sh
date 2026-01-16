#!/bin/bash

# Script deploy DolphinScheduler lên UAT
# Sử dụng: ./deploy-uat.sh

NAMESPACE="bnctl-dolphinscheduler-uat-ns"

echo "=========================================="
echo "DolphinScheduler UAT Deployment"
echo "=========================================="
echo ""

# Kiểm tra namespace có tồn tại không
if kubectl get namespace $NAMESPACE &>/dev/null; then
    echo "⚠️  Namespace $NAMESPACE đã tồn tại!"
    echo ""
    read -p "Bạn có muốn XÓA namespace cũ và tạo lại? (yes/no): " confirm
    
    if [ "$confirm" == "yes" ]; then
        echo ""
        echo "Đang xóa namespace $NAMESPACE..."
        kubectl delete namespace $NAMESPACE
        echo "Đợi namespace được xóa hoàn toàn..."
        sleep 5
        
        # Đợi namespace được xóa xong
        while kubectl get namespace $NAMESPACE &>/dev/null; do
            echo "Đang đợi namespace được xóa..."
            sleep 2
        done
        echo "✅ Namespace đã được xóa."
    else
        echo "Đã hủy. Sử dụng 'kubectl delete namespace $NAMESPACE' để xóa thủ công."
        exit 1
    fi
fi

# Tạo namespace mới
echo ""
echo "Đang tạo namespace $NAMESPACE..."
kubectl create namespace $NAMESPACE
if [ $? -ne 0 ]; then
    echo "❌ Lỗi khi tạo namespace!"
    exit 1
fi
echo "✅ Namespace đã được tạo."
echo ""

# Apply các file theo thứ tự
echo "=========================================="
echo "Đang apply các file YAML..."
echo "=========================================="
echo ""

# 1. ServiceAccount
echo "[1/10] Applying uat-serviceaccount.yaml..."
kubectl apply -f uat-serviceaccount.yaml
if [ $? -ne 0 ]; then
    echo "❌ Lỗi khi apply serviceaccount!"
    exit 1
fi
sleep 1

# 2. Secret
echo "[2/10] Applying uat-secret.yaml..."
kubectl apply -f uat-secret.yaml
if [ $? -ne 0 ]; then
    echo "❌ Lỗi khi apply secret!"
    exit 1
fi
sleep 1

# 3. ConfigMaps
echo "[3/10] Applying uat-cm.yaml..."
kubectl apply -f uat-cm.yaml
if [ $? -ne 0 ]; then
    echo "❌ Lỗi khi apply configmaps!"
    exit 1
fi
sleep 1

# 4. PVCs
echo "[4/10] Applying uat-pvc.yaml..."
kubectl apply -f uat-pvc.yaml
if [ $? -ne 0 ]; then
    echo "❌ Lỗi khi apply PVCs!"
    exit 1
fi
sleep 2

# 5. Services
echo "[5/10] Applying uat-services.yaml..."
kubectl apply -f uat-services.yaml
if [ $? -ne 0 ]; then
    echo "❌ Lỗi khi apply services!"
    exit 1
fi
sleep 2

# 6. Zookeeper
echo "[6/10] Applying uat-cluster-zookeeper.yaml..."
kubectl apply -f uat-cluster-zookeeper.yaml
if [ $? -ne 0 ]; then
    echo "❌ Lỗi khi apply zookeeper!"
    exit 1
fi
echo "   Đợi Zookeeper khởi động (10 giây)..."
sleep 10

# 7. Master
echo "[7/10] Applying uat-cluster-master.yaml..."
kubectl apply -f uat-cluster-master.yaml
if [ $? -ne 0 ]; then
    echo "❌ Lỗi khi apply master!"
    exit 1
fi
sleep 2

# 8. Worker
echo "[8/10] Applying uat-cluster-worker.yaml..."
kubectl apply -f uat-cluster-worker.yaml
if [ $? -ne 0 ]; then
    echo "❌ Lỗi khi apply worker!"
    exit 1
fi
sleep 2

# 9. API
echo "[9/10] Applying uat-cluster-api.yaml..."
kubectl apply -f uat-cluster-api.yaml
if [ $? -ne 0 ]; then
    echo "❌ Lỗi khi apply api!"
    exit 1
fi
sleep 2

# 10. Alert
echo "[10/10] Applying uat-cluster-alert.yaml..."
kubectl apply -f uat-cluster-alert.yaml
if [ $? -ne 0 ]; then
    echo "❌ Lỗi khi apply alert!"
    exit 1
fi

echo ""
echo "=========================================="
echo "✅ Đã apply tất cả các file thành công!"
echo "=========================================="
echo ""
echo "Đang kiểm tra trạng thái pods..."
echo ""
kubectl get pods -n $NAMESPACE
echo ""
echo "Để xem chi tiết, chạy:"
echo "  kubectl get all,pvc,cm,secret -n $NAMESPACE"
echo ""
echo "Để theo dõi pods, chạy:"
echo "  kubectl get pods -n $NAMESPACE -w"

