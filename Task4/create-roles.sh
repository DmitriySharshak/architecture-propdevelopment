echo "=== Создание ролей Kubernetes ==="

# Создаем namespace для разных команд
kubectl create namespace client-services
kubectl create namespace housing-services
kubectl create namespace finance
kubectl create namespace data-platform

# 1. ClusterRole для администраторов кластера (уже существует по умолчанию)
# cluster-admin - встроенная роль

# 2. Роль для администраторов namespace
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: namespace-admin
rules:
- apiGroups: ["", "apps"]
  resources: ["pods", "pods/log", "deployments", "services", "configmaps", "persistentvolumeclaims", "ingresses"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list", "watch"]  # Только просмотр секретов
- apiGroups: ["", "apps"]
  resources: ["statefulsets", "daemonsets", "replicasets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
EOF

# 4. Роль для просмотра ресурсов
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: viewer
rules:
- apiGroups: ["", "apps"]
  resources: ["pods", "pods/log", "deployments", "services", "configmaps", "ingresses"]
  verbs: ["get", "list", "watch"]
EOF
