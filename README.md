# Zabbix 8.0 LTS – automatická instalace pomocí Vagrantu

## Popis projektu

Tento projekt slouží k automatické instalaci monitorovacího systému **Zabbix 8.0 LTS** na virtuální server s operačním systémem **Debian 13**.

Virtuální stroj je vytvářen pomocí nástroje Vagrant a poskytovatele VirtualBox. Instalace Zabbix serveru, databáze a agenta probíhá automaticky pomocí shell skriptů.

## Použité technologie

- Debian 13
- Vagrant
- VirtualBox
- Zabbix Server 8.0 LTS
- Zabbix Agent 2
- MariaDB
- Apache
- Bash

## Struktura projektu

```text
.
├── Images/
│   └── screenshoty projektu
├── scripts/
│   ├── install-zabbix-server.sh
│   └── install-zabbix-agent2.sh
├── Zabbix/
│   └── export/
│       ├── sposdk.cz_hosts.json
│       ├── sposdk.cz_hosts.xml
│       └── sposdk.cz_hosts.yaml
├── .gitignore
├── Vagrantfile
├── LICENSE
└── README.md
```

## Požadavky

Před spuštěním projektu je potřeba mít nainstalováno:

- Oracle VM VirtualBox
- Vagrant
- Git (pro stažení projektu)

## Spuštění projektu

1. Naklonování repozitáře:

```bash
git clone https://github.com/sposdknl/z4vod-osy-2026-zbx8-inst.git
```

2. Přechod do složky projektu:

```bash
cd z4vod-osy-2026-zbx8-inst
```

3. Vytvoření virtuálního stroje a automatická instalace:

```bash
vagrant up
```

Vagrant vytvoří virtuální stroj s Debianem 13 a spustí instalační skripty.

## Přístup k virtuálnímu stroji

Připojení přes SSH:

```bash
vagrant ssh
```

Opětovné spuštění provisioningu:

```bash
vagrant provision
```

Zastavení virtuálního stroje:

```bash
vagrant halt
```

Odstranění virtuálního stroje:

```bash
vagrant destroy
```

## Přístup k webovému rozhraní

Po dokončení instalace je Zabbix dostupný v internetovém prohlížeči na adrese:

**http://localhost:8080**

Výchozí přihlašovací údaje Zabbixu:

- Uživatelské jméno: `Admin`
- Heslo: `zabbix`

Po prvním přihlášení doporučuji změnit výchozí heslo.

Název serveru nastavený v projektu:

`z4vod - Zabbix 8.0`

## Síťová konfigurace

Virtuální stroj používá následující přesměrování portů:

| Služba | Port virtuálního stroje | Port hostitele |
|---|---:|---:|
| SSH | 22 | 2206 |
| HTTP | 80 | 8080 |
| Zabbix Server | 10051 | 10051 |

Porty hostitele jsou navázány na adresu `127.0.0.1`.

## Databáze a zabezpečení hesel

Pro ukládání dat se používá MariaDB a databáze `zabbix`.

Heslo databázového uživatele je generováno automaticky pomocí nástroje OpenSSL. Heslo se ukládá uvnitř virtuálního stroje do souboru:

`/root/.zabbix-db-password`

Konfigurační soubor webového rozhraní `zabbix.conf.php` se vytváří automaticky uvnitř virtuálního stroje.

Hesla nejsou součástí repozitáře.

## Ověření běhu služeb

Stav hlavních služeb lze ověřit příkazem:

```bash
sudo systemctl is-active zabbix-server apache2 mariadb zabbix-agent2
```

Všechny služby by měly vrátit stav:

```text
active
```

## Řešení problémů při instalaci

Během instalace bylo potřeba vyřešit konfiguraci GRUB, která při aktualizaci Debianu vyžadovala výběr zařízení pro instalaci zavaděče. V projektu je proto před aktualizací systému automaticky nastaven disk `/dev/sda`.

Dále bylo potřeba opravit cestu k SQL schématu Zabbixu. Použitá cesta je:

`/usr/share/zabbix/sql-scripts/mysql/server.sql.gz`

Import databázového schématu se provádí pouze v případě, že databáze ještě neobsahuje tabulky Zabbixu.

## Screenshoty

V adresáři `Images/` budou umístěny screenshoty dokumentující:

- Webové rozhraní Zabbixu s vlastním názvem serveru.
- Dostupnost místního hosta a aktuální data agenta.
- Monitoring TLS/SSL certifikátu `sposdk.cz`.
- Ověření běhu jednotlivých služeb.

## Repozitář

Zdrojové soubory projektu jsou dostupné na GitHubu:

https://github.com/sposdknl/z4vod-osy-2026-zbx8-inst
