
#!/usr/bin/env bash
set -Eeuo pipefail

echo "=== Instalace Zabbix Agent 2 ==="

export DEBIAN_FRONTEND=noninteractive

apt-get install -y zabbix-agent2

echo "=== Konfigurace agenta ==="

CONFIG="/etc/zabbix/zabbix_agent2.conf"

# Nastaveni parametru, i kdyz jsou puvodne zakomentovane
set_parameter() {
    KEY="$1"
    VALUE="$2"

    if grep -Eq "^[[:space:]]*#?[[:space:]]*${KEY}=" "$CONFIG"; then
        sed -i -E "s|^[[:space:]]*#?[[:space:]]*${KEY}=.*|${KEY}=${VALUE}|" "$CONFIG"
    else
        echo "${KEY}=${VALUE}" >> "$CONFIG"
    fi
}

set_parameter "Server" "127.0.0.1"
set_parameter "ServerActive" "127.0.0.1"
set_parameter "Hostname" "debian13"

echo "=== Spusteni agenta ==="

systemctl enable --now zabbix-agent2
systemctl restart zabbix-agent2

echo "=== Zabbix Agent 2 dokoncen ==="
