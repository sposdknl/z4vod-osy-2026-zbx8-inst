
IMAGE_NAME = "bento/debian-13"

Vagrant.configure("2") do |config|
    config.ssh.insert_key = false

    config.vm.provider "virtualbox" do |v|
        v.memory = 2048
        v.cpus = 2
    end

    config.vm.define "debian" do |debian|
        debian.vm.box = IMAGE_NAME

        # SSH pristup
        debian.vm.network "forwarded_port",
            guest: 22,
            host: 2206,
            host_ip: "127.0.0.1"

        # Webove rozhrani Zabbixu
        debian.vm.network "forwarded_port",
            guest: 80,
            host: 8080,
            host_ip: "127.0.0.1"

        # Zabbix Server
        debian.vm.network "forwarded_port",
            guest: 10051,
            host: 10051,
            host_ip: "127.0.0.1"

        debian.vm.hostname = "debian13"
    end

    # Automaticka instalace Zabbix Serveru
    config.vm.provision "shell",
        path: "scripts/install-zabbix-server.sh",
        privileged: true

    # Automaticka instalace Zabbix Agent 2
    config.vm.provision "shell",
        path: "scripts/install-zabbix-agent2.sh",
        privileged: true

end
