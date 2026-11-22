# FTP con Vagrant y Ansible

Autor: Borja Valdearenas Cano

Repositorio: <https://github.com/B-V-C/ftp-vagrant-ansible>

## 1. Introducción

El objetivo de esta práctica es montar tres máquinas virtuales con Debian 12 (Bookworm) usando Vagrant y VirtualBox y, en lugar de configurarlas a mano una por una, hacerlo todo con Ansible.

Las tres máquinas comparten la red privada `192.168.57.0/24`:

- `dns.borja.test` (`192.168.57.5`): es el servidor DNS, con BIND9, y se encarga de resolver los nombres del dominio `borja.test`.
- `ansible.borja.test` (`192.168.57.6`): es el nodo de control. Desde aquí se lanzan los playbooks que configuran las otras dos máquinas.
- `negocio.borja.test` (`192.168.57.7`): hace de servidor web con Apache y de servidor FTP con vsftpd. Los nombres `www.borja.test` y `ftp.borja.test` son alias que apuntan a ella.

En cuanto al FTP, la idea es que sea seguro. Las conexiones van cifradas con TLS mediante un certificado autofirmado, el acceso anónimo está desactivado y solo pueden entrar los usuarios locales `juan` y `ana`. `juan` queda encerrado en su carpeta personal, mientras que `ana` puede subir páginas a `/var/www/html` para que Apache las sirva.

Para organizar el trabajo he usado issues y un tablero de GitHub Projects.

## 2. Herramientas

- **Vagrant**: para crear y configurar las máquinas virtuales.
- **VirtualBox**: el programa que ejecuta esas máquinas.
- **Debian 12**: el sistema operativo de las tres.
- **Ansible**: instala y configura los servicios a través de playbooks.
- **Ansible Vault**: lo uso para guardar cifrados los hashes de las contraseñas de los usuarios FTP.
- **BIND9**: el software del servidor DNS.
- **Apache**: el servidor web.
- **vsftpd**: el servidor FTP.
- **FileZilla**: el cliente FTP con el que he hecho las pruebas.
- **Git y GitHub**: para el control de versiones y el historial de cambios. Con las issues y GitHub Projects llevo además el seguimiento de las tareas.

## 3. Cómo ejecutar el proyecto

Para poner en marcha el proyecto hace falta tener instalados Vagrant y VirtualBox. Hay que tener en cuenta que cada máquina usa 2 GB de RAM, por lo que se necesitan unos 6 GB libres.

Lo primero es clonar el repositorio y entrar en la carpeta:

```bash
git clone https://github.com/B-V-C/ftp-vagrant-ansible.git
cd ftp-vagrant-ansible
```

Las contraseñas de los usuarios FTP están cifradas con Ansible Vault en `ftp/vars/vault.yml`. Como la contraseña del vault no se sube al repositorio, antes de arrancar hay que crear en la raíz del proyecto un fichero `vault_pass.txt` que contenga únicamente esa contraseña. En PowerShell se puede hacer así (sustituyendo `CONTRASEÑA` por la del vault):

```bash
Set-Content -Path vault_pass.txt -Value "CONTRASEÑA" -NoNewline
```

Una vez creado, basta con ejecutar:

```bash
vagrant up
```

Vagrant crea las tres máquinas y, en la de `ansible`, ejecuta el script `script/ansible.sh`. Este script instala Ansible, copia los ficheros necesarios y lanza los tres playbooks (DNS, web y FTP). Cuando termina, todo queda instalado y funcionando sin tener que hacer nada más.

Para comprobar que todo funciona se pueden lanzar los scripts de prueba:

```bash
vagrant ssh dns -c "bash /vagrant/dns/test-dns.sh"
```

```bash
vagrant ssh ansible -c "bash /vagrant/web/test-web.sh"
```

Si se quieren usar los nombres `www.borja.test` y `ftp.borja.test` desde el propio ordenador, hay que configurar `192.168.57.5` como servidor DNS. En [la documentación](doc/README.md) explico cómo lo hice yo en Windows.

Otros comandos útiles:

- **Volver a lanzar el script y los playbooks:**

```bash
vagrant provision ansible
```

- **Ver el estado de las máquinas:**

```bash
vagrant status
```

- **Detenerlas:**

```bash
vagrant halt
```

- **Eliminarlas:**

```bash
vagrant destroy -f
```

Todo el proceso, con capturas y los problemas que me fui encontrando, está documentado en [doc/README.md](doc/README.md).

## 4. Licencia

El proyecto está bajo la licencia GNU General Public License v3.0. La elegí porque es la misma que usa Ansible y porque obliga a que cualquier versión modificada siga siendo libre.
