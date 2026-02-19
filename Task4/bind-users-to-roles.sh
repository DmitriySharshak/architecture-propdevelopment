echo "=== Привязка пользователей к ролям ==="

# 1. Привязка cluster-admin для администраторов инфраструктуры
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-admins-binding
subjects:
- kind: User
  name: ivan-ivanov
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF

# 2. Привязка namespace-admin для client-services
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: client-services-admins
  namespace: client-services
subjects:
- kind: User
  name: alexey-smirnov
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: namespace-admin
  apiGroup: rbac.authorization.k8s.io
EOF

# 3. Привязка namespace-admin для housing-services
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: housing-services-admins
  namespace: housing-services
subjects:
- kind: User
  name: alexey-smirnov
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: namespace-admin
  apiGroup: rbac.authorization.k8s.io
EOF

# 4. Привязка viewer 
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: viewers-binding
subjects:
- kind: User
  name: dmitry-kuznetsov
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: viewer
  apiGroup: rbac.authorization.k8s.io
EOF

echo "=== Проверка созданных привязок ==="
echo "ClusterRoleBindings:"
kubectl get clusterrolebindings | grep -E "cluster-admins-binding|viewers-binding"

echo -e "\nRoleBindings в namespace client-services:"
kubectl get rolebindings -n client-services

echo -e "\nRoleBindings в namespace housing-services:"
kubectl get rolebindings -n housing-services

echo "=== Все привязки успешно созданы ==="