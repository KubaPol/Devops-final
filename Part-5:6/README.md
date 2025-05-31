Проект DevOps: VPN, мониторинг и бэкапы
Общая информация

Платформа: Yandex Cloud.
Аккаунты:
kubapol (vpn-server, IP: 89.169.172.156).
superpokemon25 (ca-server, IP: 84.201.189.183).



Состав проекта

VPN-сервер: OpenVPN с Easy-RSA для управления сертификатами.
Мониторинг: Prometheus, Grafana, Alertmanager, экспортёры (node_exporter, openvpn-exporter).
CA-сервер: Easy-RSA и хранилище бэкапов.
Бэкапы: Скрипт backup.sh для автоматизации.

Адреса и порты

vpn-server (89.169.172.156):
OpenVPN: 1194 (VPN-доступ).
Prometheus: 9090 (сбор метрик).
Grafana: 3000 (визуализация).
Alertmanager: 9093 (уведомления).
node_exporter: 9100 (метрики системы).
openvpn-exporter: 9176 (метрики VPN).


ca-server (84.201.189.183):
SSH: 22 (передача бэкапов).
node_exporter: 9100 (метрики системы).



Схемы

Инфраструктура: infrastructure_diagram.png — показывает серверы, их IP и сервисы.
Потоки данных: data_flow_diagram.png — иллюстрирует взаимодействие компонентов (пользователь → VPN → CA, сбор метрик, уведомления).

Настройка
VPN-сервер

Создайте машину в Yandex Cloud:yc compute instance create --name vpn-server --zone ru-central1-a --public-ip


Установите зависимости:sudo apt update
sudo apt install openvpn easy-rsa prometheus grafana alertmanager prometheus-node-exporter


Настройте OpenVPN и мониторинг:
Конфигурации: /etc/openvpn, /etc/prometheus, /etc/alertmanager.
Логи: /var/log/openvpn.



CA-сервер

Создайте машину в Yandex Cloud:yc compute instance create --name ca-server --zone ru-central1-a --public-ip


Установите зависимости:sudo apt update
sudo apt install easy-rsa prometheus-node-exporter


Настройте Easy-RSA и хранилище бэкапов:
PKI: /home/superpokemon25/easy-rsa/pki.
Хранилище: /backup (права 700, владелец superpokemon25).



Бэкапы

Подробное описание системы резервного копирования: backup_design.md.
Ключевые моменты:
Ежедневный запуск в 02:00 UTC.
Передача через SSH (порт 22).
Уведомления через Alertmanager на super.pokemon25@yandex.ru.



Мониторинг

Prometheus: Собирает метрики с node_exporter (9100) и openvpn-exporter (9176).
Grafana: Визуализация метрик (доступ по порту 3000).
Alertmanager: Уведомления (успех — info, ошибка передачи — warning, ошибка создания — critical).

Файлы

backup_design.md — описание системы бэкапов.
vpn_user_guide.md — инструкция для пользователей VPN.
backup.sh — скрипт бэкапирования.
my-backup-package_1.0-1_all.deb — deb-пакет для автоматизации.
iptables.sh — настройка iptables.
infrastructure_diagram.png, data_flow_diagram.png — схемы.

Автор

Email: super.pokemon25@yandex.ru.


