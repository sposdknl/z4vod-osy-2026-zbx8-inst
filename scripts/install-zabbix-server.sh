
#!/usr/bin/env bash
set -Eeuo pipefail

echo "=== Aktualizace Debianu ==="

export DEBIAN_FRONTEND=noninteractive

echo 'grub-pc grub-pc/install_devices multiselect /dev/sda' | debconf-set-selections

apt-get update
apt-get upgrade -y

echo "=== Instalace MariaDB a Apache ==="

apt-get install -y \
    mariadb-server \
    apache2 \
    wget \
    ca-certificates \
    openssl

systemctl enable --now mariadb

echo "=== Instalace repozitare Zabbix 8.0 ==="

wget -q -O /tmp/zabbix-release.deb \
    https://repo.zabbix.com/zabbix/8.0/release/debian/pool/main/z/zabbix-release/zabbix-release_latest+debian13_all.deb

dpkg -i /tmp/zabbix-release.deb

apt-get update

echo "=== Instalace Zabbix Serveru ==="

apt-get install -y \
    zabbix-server-mysql \
    zabbix-frontend-php \
    zabbix-apache-conf \
    zabbix-sql-scripts

echo "=== Konfigurace databaze ==="

DB_PASS_FILE="/root/.zabbix-db-password"

if [ ! -s "$DB_PASS_FILE" ]; then
    openssl rand -hex 24 > "$DB_PASS_FILE"
    chmod 600 "$DB_PASS_FILE"
fi

DB_PASS=$(cat "$DB_PASS_FILE")

mysql <<SQL
CREATE DATABASE IF NOT EXISTS zabbix
CHARACTER SET utf8mb4
COLLATE utf8mb4_bin;

CREATE USER IF NOT EXISTS 'zabbix'@'localhost'
IDENTIFIED BY '${DB_PASS}';

ALTER USER 'zabbix'@'localhost'
IDENTIFIED BY '${DB_PASS}';

GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';

SET GLOBAL log_bin_trust_function_creators = 1;

FLUSH PRIVILEGES;
SQL

echo "=== Import databazoveho schema ==="

TABLE_EXISTS=$(mysql -Nse \
    "SELECT COUNT(*) FROM information_schema.tables
     WHERE table_schema='zabbix' AND table_name='users';")

if [ "$TABLE_EXISTS" -eq 0 ]; then
	zcat /usr/share/zabbix/sql-scripts/mysql/server.sql.gz \
        | mysql --default-character-set=utf8mb4 zabbix
else
    echo "Databazove schema uz existuje, import preskakuji."
fi

mysql -e "SET GLOBAL log_bin_trust_function_creators = 0;"

echo "=== Konfigurace Zabbix Serveru ==="

if grep -q '^DBPassword=' /etc/zabbix/zabbix_server.conf; then
    sed -i "s|^DBPassword=.*|DBPassword=${DB_PASS}|" \
        /etc/zabbix/zabbix_server.conf
else
    echo "DBPassword=${DB_PASS}" >> /etc/zabbix/zabbix_server.conf
fi

echo "=== Konfigurace weboveho rozhrani ==="

cat > /etc/zabbix/web/zabbix.conf.php <<EOF
<?php
\$DB['TYPE'] = 'MYSQL';
\$DB['SERVER'] = 'localhost';
\$DB['PORT'] = '0';
\$DB['DATABASE'] = 'zabbix';
\$DB['USER'] = 'zabbix';
\$DB['PASSWORD'] = '${DB_PASS}';

\$ZBX_SERVER = 'localhost';
\$ZBX_SERVER_PORT = '10051';
\$ZBX_SERVER_NAME = 'z4vod - Zabbix 8.0';

\$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
EOF

chown root:www-data /etc/zabbix/web/zabbix.conf.php
chmod 640 /etc/zabbix/web/zabbix.conf.php

echo "=== Spusteni sluzeb ==="

systemctl enable zabbix-server apache2
systemctl restart zabbix-server apache2

echo "=== Instalace Zabbix Serveru dokoncena ==="
