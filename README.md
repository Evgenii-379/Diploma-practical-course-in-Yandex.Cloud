# Дипломный практикум в Yandex.Cloud - ***Вуколов Евгений***

- [Цели:](#цели)
- [Этапы выполнения:](#этапы-выполнения)
- [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
- [Создание Kubernetes кластера](#создание-kubernetes-кластера)
- [Создание тестового приложения](#создание-тестового-приложения)
- [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
- [Установка и настройка CI/CD](#установка-и-настройка-cicd)
- [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
- [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)
 
**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**
 
---
## Цели:
 
1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.
 
---
## Этапы выполнения:
 
### Создание облачной инфраструктуры
 
Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).
 
Особенности выполнения:
 
- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.
 
Предварительная подготовка к установке и запуску Kubernetes кластера.
 
1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://developer.hashicorp.com/terraform/language/backend) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)
3. Создайте конфигурацию Terrafrom, используя созданный бакет ранее как бекенд для хранения стейт файла. Конфигурации Terraform для создания сервисного аккаунта и бакета и основной инфраструктуры следует сохранить в разных папках.
4. Создайте VPC с подсетями в разных зонах доступности.
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://developer.hashicorp.com/terraform/language/backend) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.
 
Ожидаемые результаты:
 
1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий, стейт основной конфигурации сохраняется в бакете или Terraform Cloud
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.
 
---
### Создание Kubernetes кластера
 
На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.
 
Это можно сделать двумя способами:
 
1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:
 
1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.
 
---
### Создание тестового приложения
 
Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.
 
Способ подготовки:
 
1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.
 
Ожидаемый результат:
 
1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.
 
---
### Подготовка cистемы мониторинга и деплой приложения
 
Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.
 
Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.
 
Способ выполнения:
1. Воспользоваться пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). Альтернативный вариант - использовать набор helm чартов от [bitnami](https://github.com/bitnami/charts/tree/main/bitnami).
 
2. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.
 
Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ на 80 порту к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ на 80 порту к тестовому приложению.
5. Atlantis или terraform cloud или ci/cd-terraform
---
### Установка и настройка CI/CD
 
Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.
 
Цель:
 
1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.
 
Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.
 
Ожидаемый результат:
 
1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.
 
---
## Что необходимо для сдачи задания?
 
1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)


# **Выполнение дипломного практикума**


## Содержание

- [1. Инфраструктура (Terraform)](#1-инфраструктура-terraform)
- [2. CI/CD (GitHub Actions)](#2-cicd-github-actions)
- [3. Docker-приложение](#3-docker-приложение)
- [4. Kubernetes конфигурации](#4-kubernetes-конфигурации)
- [5. Мониторинг (Prometheus + Grafana)](#5-мониторинг-prometheus--grafana)
- [6. Доступы и ссылки](#6-доступы-и-ссылки) 
- [7. Скриншоты](#7-скриншоты)
- [8. Репозитории](#8-репозитории)

---

- Этот проект — результат выполнения дипломного практикума в Яндекс.Облаке. В рамках работы был реализован полный цикл DevOps-практик: от развертывания инфраструктуры с помощью
Terraform до CI/CD и мониторинга через Prometheus + Grafana. Для создания я использовал рекомендуемый вариант: самостоятельная установка Kubernetes кластера.
В YC развёрнуто 4 VM: bastion, k8s-node1, k8s-node2, k8s-node3. Мастером является - k8s-node1. На bastion был скачен Kubespray и с помощью него создан  Kubernetes кластер. Так же на бастионе
настроен файл inventory.ini для подключения к VM.

- Готовая структура проекта в локальном репозитории:

- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-27%20152136.png)

- Настройка файла inventory.ini на VM bastion для использования kubespray:

- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-27%20145628.png)
- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-27%20145547.png)


## 1. Инфраструктура (Terraform)

**Репозиторий:** [`Diploma-practical-course-in-Yandex.Cloud`](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud)

Структура папок:

- iac-terraform/ — сервисный аккаунт, назначение ролей,провайдер, аутенцификация через токен, cloud, folder
- infra/ — VPC сеть с именем main-network, подсети в разных зонах доступности
- k8s_cluster/ — кластер Kubernetes
- s3_bucket/ — бакет для хранения стейт-файлов

- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-28%20160103.png)
- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-18%20223023.png)

- Роли для сервисных аккаунтов: 

- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-19%20142559.png)



Все модули были применены с нуля через `terraform init / plan / apply`.

---

## 2. CI/CD (GitHub Actions)


**Репозиторий:** [`test-nginx-app`](https://github.com/Evgenii-379/test-nginx-app)

Что реализовано:
- Сборка и публикация Docker-образа в Yandex Container Registry
- Развёртывание нового образа в кластер Kubernetes при пуше тега
- Использование секретов (`YC_REGISTRY_ID`, `KUBECONFIG`, `YC_SERVICE_ACCOUNT_KEY_BASE64`)

Workflow: `.github/workflows/docker-build.yml`

- Секреты в Github:

- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-28%20213502.png)
- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-28%20213515.png)

- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-28%20213637.png)
- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-28%20213650.png)

- Сборка образов :

- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-25%20221819.png)

- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-25%20221904.png)

- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-25%20222051.png)

- Сборка docker образа с тегом v1.0.6 :

- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-26%20231834.png) 
- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-26%20232317.png)
- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-26%20231528.png)
- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-26%20231457.png)
- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-26%20233542.png)
- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-26%20234915.png)

---

## 3. Docker-приложение

**Репозиторий:** [`test-nginx-app`](https://github.com/Evgenii-379/test-nginx-app)

Минимальное Nginx-приложение:

- `Dockerfile`
- `index.html`
- `nginx.conf`

Образы публикуются в:

- cr.yandex/crpndta336ndd7sejlna/test-nginx-app:<tag>


- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-21%20151459.png)
- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-23%20135809.png)
- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-30%20223825.png)

---

## 4. Kubernetes конфигурации

**Репозиторий:** [`k8s-configs`](https://github.com/Evgenii-379/k8s-configs)

Файлы:
- `deployment.yaml`
- `service.yaml`
- `ingress.yaml`

- Развёртывание Kubernetes на 3-х нодах:

- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-17%20234544.png)

- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-23%20135809.png)

- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-23%20141040.png)

- Вывод команды 'kubectl get pods --all-namespaces' на VM bastion и на мастер ноде : 

- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-18%20004624.png)
- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-18%20005349.png)

- Kubernetes секрет для доступа к YCR :

- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-19%20143747.png)

---

## 5. Мониторинг (Prometheus + Grafana)

- Установлен через `monitoring/grafana-ingress.yaml`
- Grafana доступна через Ingress
- Node Exporter настроен

- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-22%20115319.png)
- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-23%20133850.png)


Для вывода информации о нодах, я использовал готовые дашборды.

- Дашборды с информацией о нодах:


- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-23%20220835.png)
- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-23%20221021.png)

- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-23%20221033.png)
- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-23%20221049.png)

- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-23%20221103.png)
- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-23%20221118.png)

- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-23%20221317.png)
- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-23%20221335.png)
- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-23%20221402.png)
- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-23%20221415.png)


---

## 6. Доступы и ссылки

| Назначение       | Ссылка / Комментарий                                                                      |
|------------------|-------------------------------------------------------------------------------------------|
| App              | [http://158.160.180.8:31075/nginx](http://158.160.180.8:31075/nginx)                      |
| Grafana          | [http://158.160.180.8:31075](http://158.160.180.8:31075)  логин: `admin`, пароль: `admin` |
| Docker Image     | `cr.yandex/crpndta336ndd7sejlna/test-nginx-app:v1.0.6`                                    |
| CI/CD Logs       | [GitHub Actions](https://github.com/Evgenii-379/test-nginx-app/actions)                   |
| Grafana Dashboard| `Node Exporter Full` настроен                                                             |

---

## 7. Скриншоты

Файлы находятся в папке [`Diploma-practical-course-in-Yandex.Cloud/images`](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/tree/main/images)

Примеры:
- Успешный GitHub Actions
- Интерфейс Grafana
- `kubectl logs`, `kubectl get` выводы
- Состояние Docker Registry

---

## 8. Репозитории :

Docker + GitHub Actions:

[test-nginx-app](https://github.com/Evgenii-379/test-nginx-app) 
 
Terraform инфраструктура:

[Diploma-practical-course-in-Yandex.Cloud](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud) 

Манифесты K8s:

[k8s-configs](https://github.com/Evgenii-379/k8s-configs)

---

##  Результат

- ![scrin](https://github.com/Evgenii-379/Diploma-practical-course-in-Yandex.Cloud/blob/main/images/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-05-27%20000447.png)


- Инфраструктура создаётся с нуля
- Автоматическая сборка Docker-образа при любом коммите
- Автозагрузка в YCR
- Автоматический деплой в Kubernetes при теге
- Полностью рабочая GitHub Actions CI/CD-платформа
- Приложение доставляется через CI/CD
- Наблюдаемость настроена через Grafana
- Все этапы автоматизированы

---


