# Zabbix 8.0 LTS – automatická instalace pomocí Vagrantu

## Popis projektu

Tento projekt slouží k automatické instalaci monitorovacího systému **Zabbix 8.0 LTS** na virtuální server s operačním systémem **Debian 13**.

Virtuální stroj je vytvářen pomocí nástroje Vagrant a poskytovatele VirtualBox. Instalace Zabbix serveru, databáze, webového rozhraní a agenta probíhá automaticky pomocí shell skriptů.

Projekt obsahuje také export konfigurace hostitele `sposdk.cz` pro monitoring TLS/SSL certifikátu a obrazovou dokumentaci instalace.

## Použité technologie

- Debian 13
- Vagrant
- Oracle VirtualBox
- Zabbix Server 8.0 LTS
- Zabbix Agent 2
- MariaDB
- Apache
- Bash
- Git a GitHub

## Struktura projektu

```text
.
├── Images/
│   ├── zabbix-obrazek.png
│   ├── screenshoty instalace a konfigurace
│   └── screenshoty monitoringu
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

Vagrant vytvoří virtuální stroj s Debianem 13 a automaticky spustí instalační skripty pro Zabbix Server a Zabbix Agent 2.

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

Vlastní název serveru nastavený v projektu:

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

Citlivé údaje nejsou součástí repozitáře.

## Ověření běhu služeb

Stav hlavních služeb lze ověřit příkazem:

```bash
sudo systemctl is-active zabbix-server apache2 mariadb zabbix-agent2
```

Všechny čtyři služby by měly vrátit stav:

```text
active
```

## Monitoring hostitele sposdk.cz

V adresáři `Zabbix/export/` jsou připraveny exporty konfigurace hostitele `sposdk.cz` ve formátech JSON, XML a YAML.

Konfigurace je určena pro monitoring TLS/SSL certifikátu webové stránky:

`https://sposdk.cz`

Použitá skupina hostitelů:

`Web Certificate`

Použitá šablona:

`Website certificate by Zabbix agent 2`

Exporty slouží k přenosu konfigurace do Zabbixu.

## Řešení problémů při instalaci

Během instalace bylo potřeba vyřešit konfiguraci GRUB, která při aktualizaci Debianu vyžadovala výběr zařízení pro instalaci zavaděče. V projektu je proto před aktualizací systému automaticky nastaven disk `/dev/sda`.

Dále bylo potřeba opravit cestu k SQL schématu Zabbixu. Použitá cesta je:

`/usr/share/zabbix/sql-scripts/mysql/server.sql.gz`

Import databázového schématu se provádí pouze v případě, že databáze ještě neobsahuje tabulky Zabbixu.

## Screenshoty a obrazová dokumentace

V adresáři `Images/` jsou uloženy vlastní obrázky a screenshoty dokumentující projekt.

Obrazová dokumentace zahrnuje:

- Vlastní obrázek související se Zabbixem.
- Webové rozhraní Zabbixu s vlastním názvem serveru.
- Konfiguraci a monitoring v Zabbixu.
- Další screenshoty průběhu projektu.

## Git a GitHub

Projekt je verzován pomocí systému Git a uložen na GitHubu.

Soubor `.gitignore` obsahuje pravidla pro ignorování lokálních a citlivých souborů:

```gitignore
.vagrant/
*.log
.env
zabbix.conf.php
```

Složka `.vagrant/` obsahuje lokální data Vagrantu a není součástí GitHub repozitáře. Díky tomu se do repozitáře nenahrávají lokální data virtuálního stroje ani jeho konfigurace.

## Repozitář

Zdrojové soubory projektu jsou dostupné na GitHubu:

https://github.com/sposdknl/z4vod-osy-2026-zbx8-inst