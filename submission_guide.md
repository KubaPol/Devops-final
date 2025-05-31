Описание проекта

Проект представляет собой инфраструктуру для небольшой компании, включающую VPN-сервер, CA-сервер, систему мониторинга и бэкапирования. Все компоненты автоматизированы с помощью скриптов и deb-пакетов, задокументированы и готовы к дальнейшему развитию.

Структура директорий


Part-1: Удостоверяющий центр.


Part-2: VPN-сервер.


Part-3: Мониторинг.


Part-4: Бэкапирование.


Part-5:6: Документация и план развития.

Список артефактов

Скрипты и deb-пакеты для удостоверяющего центра:

Part-1/my-ca-package.deb — deb-пакет.

Part-1/iptables.sh, Part-1/make-config.sh — скрипты.

Part-1/ca-crt.png — скриншот корневого сертификата.


Скрипты и deb-пакеты для VPN-сервера:

Part-2/my-vpn-package.deb — deb-пакет.

Part-2/iptables.sh, Part-2/make_config.sh, Part-2/backup.sh — скрипты.

Part-2/client-3.ovpn — клиентский файл.

Скриншот подключения к VPN:

Part-2/Open-VPN.PNG — показывает успешное подключение и изменение IP.



Документ с проектированием мониторинга:

Part-3/monitoring_design.md.

Скрипты и deb-пакеты для мониторинга:

Part-3/my-monitoring-package_1.0-1_all.deb — deb-пакет.

Part-3/postinst, Part-3/postrm, Part-3/control — файлы для сборки пакета.

Скриншот веб-интерфейса Prometheus:

Part-3/Alerts.png — показывает алерты.

Part-3/History_graf.png — показывает исторические данные.



Документ с описанием бэкапирования:

Part-4/backup_design.md.

Скрипты и deb-пакеты для бэкапирования:

Part-4/backup.sh — скрипт.

Part-4/my-backup-package_1.0-1_all.deb — deb-пакет.

Part-4/backup/ — примеры бэкапов.



Руководство пользователя VPN:

Part-5:6/vpn_user_guide.md.

Схема инфраструктуры:

Part-5:6/schema_1.png.

Схема потоков данных:

Part-5:6/schema_2.png.

Руководство системного администратора:

Part-5:6/README.md.

Документ с планом развития:

Part-5:6/development_plan.md.
