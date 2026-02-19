echo "=== Создание сервисов с метками ==="

# Создаем отдельный namespace для изоляции
kubectl create namespace traffic-demo --dry-run=client -o yaml | kubectl apply -f -

# Переключаемся на созданный namespace
kubectl config set-context --current --namespace=traffic-demo

# 0. удалить все поды
kubectl delete pods --all

# 1. Front-end сервис
echo "Создание front-end сервиса..."
kubectl run front-end-app --image=nginx --labels="role=front-end" --expose --port=80 -n traffic-demo
kubectl wait --for=condition=ready pod -l role=front-end -n traffic-demo --timeout=30s

# 2. Back-end API сервис
echo "Создание back-end-api сервиса..."
kubectl run back-end-api-app --image=nginx --labels="role=back-end-api" --expose --port=80 -n traffic-demo
kubectl wait --for=condition=ready pod -l role=back-end-api -n traffic-demo --timeout=30s

# 3. Admin Front-end сервис
echo "Создание admin-front-end сервиса..."
kubectl run admin-front-end-app --image=nginx --labels="role=admin-front-end" --expose --port=80 -n traffic-demo
kubectl wait --for=condition=ready pod -l role=admin-front-end -n traffic-demo --timeout=30s

# 4. Admin Back-end API сервис
echo "Создание admin-back-end-api сервиса..."
kubectl run admin-back-end-api-app --image=nginx --labels="role=admin-back-end-api" --expose --port=80 -n traffic-demo
kubectl wait --for=condition=ready pod -l role=admin-back-end-api -n traffic-demo --timeout=30s

echo ""
echo "=== Все сервисы созданы ==="
kubectl get pods -n traffic-demo -o wide
kubectl get svc -n traffic-demo

echo ""
echo "=== Метки сервисов ==="
kubectl get pods -n traffic-demo --show-labels