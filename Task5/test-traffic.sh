echo "=== Тестирование сетевой изоляции ==="
echo "Namespace: traffic-demo"
echo ""

# Функция для тестирования соединения
test_connection() {
    local FROM_POD=$1
    local TO_SERVICE=$2
    local EXPECTED=$3
    
    echo "Тест: $FROM_POD -> $TO_SERVICE"
    
    # Создаем временный под для тестирования или используем существующий
    RESULT=$(kubectl exec $FROM_POD -n traffic-demo -- curl -s --connect-timeout 5 http://$TO_SERVICE 2>&1 || echo "FAILED")
    
    if [[ "$RESULT" == *"FAILED"* ]] || [[ "$RESULT" == *"Connection timed out"* ]] || [[ "$RESULT" == *"Unable to connect"* ]]; then
        if [ "$EXPECTED" = "denied" ]; then
            echo "  ✓ Успешно: соединение заблокировано (как и ожидалось)"
        else
            echo "  ✗ ОШИБКА: соединение заблокировано (ожидалось разрешено)"
        fi
    else
        if [ "$EXPECTED" = "allowed" ]; then
            echo "  ✓ Успешно: соединение установлено (как и ожидалось)"
        else
            echo "  ✗ ОШИБКА: соединение установлено (ожидалось заблокировано)"
        fi
    fi
    echo ""
}

# Получаем имена подов
FRONT_END_POD=$(kubectl get pod -l role=front-end -n traffic-demo -o jsonpath='{.items[0].metadata.name}')
BACK_END_API_POD=$(kubectl get pod -l role=back-end-api -n traffic-demo -o jsonpath='{.items[0].metadata.name}')
ADMIN_FRONT_END_POD=$(kubectl get pod -l role=admin-front-end -n traffic-demo -o jsonpath='{.items[0].metadata.name}')
ADMIN_BACK_END_API_POD=$(kubectl get pod -l role=admin-back-end-api -n traffic-demo -o jsonpath='{.items[0].metadata.name}')

# Имена сервисов
FRONT_END_SVC="front-end-app"
BACK_END_API_SVC="back-end-api-app"
ADMIN_FRONT_END_SVC="admin-front-end-app"
ADMIN_BACK_END_API_SVC="admin-back-end-api-app"

echo "=== Тест 1: Разрешенные соединения ==="
echo "----------------------------------------"
test_connection $FRONT_END_POD $BACK_END_API_SVC "allowed"
test_connection $BACK_END_API_POD $FRONT_END_SVC "allowed"
test_connection $ADMIN_FRONT_END_POD $ADMIN_BACK_END_API_SVC "allowed"
test_connection $ADMIN_BACK_END_API_POD $ADMIN_FRONT_END_SVC "allowed"

echo "=== Тест 2: Запрещенные соединения (кросс-доменные) ==="
echo "------------------------------------------------"
test_connection $FRONT_END_POD $ADMIN_BACK_END_API_SVC "denied"
test_connection $ADMIN_FRONT_END_POD $BACK_END_API_SVC "denied"

echo "=== Тест 3: Запрещенные соединения (между бэкендами) ==="
echo "--------------------------------------------------"
test_connection $BACK_END_API_POD $ADMIN_BACK_END_API_SVC "denied"
test_connection $ADMIN_BACK_END_API_POD $BACK_END_API_SVC "denied"

echo "=== Тест 4: Запрещенные соединения (между фронтендами) ==="
echo "-----------------------------------------------------"
test_connection $FRONT_END_POD $ADMIN_FRONT_END_SVC "denied"
test_connection $ADMIN_FRONT_END_POD $FRONT_END_SVC "denied"

echo "=== Тестирование завершено ==="