echo "=== Применение сетевых политик ==="

# Убеждаемся, что мы в правильном namespace
kubectl config set-context --current --namespace=traffic-demo

# Удаляем старые политики
echo "Удаление старых политик..."
kubectl delete networkpolicy --all -n traffic-demo 2>/dev/null

# Сначала применяем политику запрета по умолчанию
echo "Применение политики default-deny-all.yaml..."
#kubectl apply -f default-deny-all.yaml

# Затем применяем разрешающие политики
echo "Применение политики non-admin-api-allow.yaml..."
kubectl apply -f non-admin-api-allow.yaml

echo "Применение политики admin-api-allow.yaml..."
kubectl apply -f admin-api-allow.yaml

echo ""
echo "=== Примененные сетевые политики ==="
kubectl get networkpolicy -n traffic-demo

echo ""
echo "=== Детали политик ==="
kubectl describe networkpolicy -n traffic-demo