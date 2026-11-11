#!/usr/bin/env bash
#
# Configura el servidor como un nodo de control de Ansible
#
set -xeu

# Instalar ansible
apt-get update
apt-get install -y ansible ansible-lint whois

#
# Copia clave privada de Vagrant para conectarse a las MVs
#
# Para evitar problemas con Windows y los permisos, en lugar de utilizar las
# claves privadas compartidas en /vagrant/.vagrant/... copiamos las claves
# privadas dentro de la MV `ansible` y establecemos los permisos adecuados
#
mkdir -p ./private_keys/{dns,negocio}
cp -vf /vagrant/.vagrant/machines/dns/virtualbox/private_key ./private_keys/dns.key.rsa
cp -vf /vagrant/.vagrant/machines/negocio/virtualbox/private_key ./private_keys/negocio.key.rsa
chown vagrant:vagrant ./private_keys/*
chmod 600 ./private_keys/*

# Copiar ficheros de ansible y playbooks
# Descomentar las siguientes líneas según vayamos teniendo los ficheros y
# hacer `vagrant provision ansible`
# cp -vf /vagrant/ansible.cfg .
# cp -vf /vagrant/inventory.yml .
cp -vf /vagrant/requirements.yml .
# cp -vrf /vagrant/dns .
# cp -vrf /vagrant/web .
# cp -vrf /vagrant/ftp .
# chown vagrant:vagrant ./ansible.cfg ./inventory.yml
# chown -R vagrant:vagrant ./{dns,web,ftp}

# Copiar contraseña del vault
# cp -vf /vagrant/vault_pass.txt ./.vault_pass.txt
# chmod 600 ./.vault_pass.txt

# Instalar dependencias de Ansible
ansible-galaxy collection install -r requirements.yml

# Provisionar con Ansible
# ansible-playbook dns/dns.yml
# ansible-playbook web/web.yml
# ansible-playbook ftp/ftp.yml --vault-password-file ./.vault_pass.txt