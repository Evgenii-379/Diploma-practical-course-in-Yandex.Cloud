# my-k8s-project

Автоматизированный проект для управления облачной инфраструктурой и кластером Kubernetes в Яндекс.Облаке с использованием **Terraform** и **GitHub Actions**.

---

## Структура проекта

# my-k8s-project
.
├── iac-terraform           # Автоматизированное применение Terraform
├── infra                   # Terraform для настройки сетей, маршрутов и т.д.
├── k8s_cluster             # Создание и конфигурация кластера
├── k8s-configs             # K8s-манифесты для приложения и мониторинга
├── s3_bucket               # Terraform для bucket'ов и хранения state
└── test-nginx-app          # Docker-контейнер тестового приложения
