echo "=== Создание пользователей для кластера Kubernetes ==="

# Создаем директорию для сертификатов
mkdir -p certs
cd certs

# Функция для создания пользователя
create_user() {
    local USERNAME=$1
    local GROUP=$2
    
    echo "Создание пользователя: $USERNAME, группа: $GROUP"
    
    # Генерация закрытого ключа
    openssl genrsa -out ${USERNAME}.key 2048
    
    # Создание запроса на сертификат (CSR)
    openssl req -new -key ${USERNAME}.key -out ${USERNAME}.csr -subj "/CN=${USERNAME}/O=${GROUP}"
    
    # Подписание сертификата Kubernetes CA (в Minikube)
    openssl x509 -req -in ${USERNAME}.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out ${USERNAME}.crt -days 365
    
    echo "Пользователь $USERNAME создан"
    echo "---"
}


# Создаем административных пользователей
#create_user "ivan-ivanov" "cluster-admins"

# Создаем админа
#create_user "alexey-smirnov" "namespace-admins"

# Создаем разработчиков
#create_user "dmitry-kuznetsov" "viewer"

# Настройка kubectl для пользователей
setup_kubectl_user() {
    local USERNAME=$1
    
    # Добавление пользователя в kubectl
    kubectl config set-credentials ${USERNAME} \
        --client-certificate=certs/${USERNAME}.crt \
        --client-key=certs/${USERNAME}.key
    
    echo "Учётные данные для $USERNAME добавлены в kubectl"
}

# Добавляем всех пользователей в kubectl
setup_kubectl_user "ivan-ivanov"
setup_kubectl_user "alexey-smirnov"
setup_kubectl_user "dmitry-kuznetsov"

echo "=== Все пользователи успешно созданы ==="
cd ..