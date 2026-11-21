# FTP con Vagrant y Ansible

Autor: Borja Valdearenas Cano

Repositorio: <https://github.com/B-V-C/ftp-vagrant-ansible>

## 1. Introducción

En esta práctica monto tres máquinas virtuales con Debian 12 (Bookworm) usando Vagrant y VirtualBox, y las configuro con Ansible en vez de hacerlo a mano en cada una.

Las máquinas están en la red privada `192.168.57.0/24`:

- `dns.borja.test` (`192.168.57.5`): servidor DNS con BIND9. Resuelve los nombres del dominio `borja.test`.
- `ansible.borja.test` (`192.168.57.6`): nodo de control. Desde aquí lanzo los playbooks que configuran las otras dos máquinas.
- `negocio.borja.test` (`192.168.57.7`): servidor web con Apache y servidor FTP con vsftpd. Los nombres `www.borja.test` y `ftp.borja.test` son alias que apuntan a esta máquina.

El FTP es seguro: las conexiones van cifradas con TLS usando un certificado autofirmado, no se permite el acceso anónimo y solo pueden entrar los usuarios locales `juan` y `ana`. `juan` se queda encerrado en su carpeta personal y `ana` puede subir páginas web a `/var/www/html`, que luego sirve Apache.

Las tareas las organizo con issues y un tablero en GitHub Projects.

## 2. Herramientas

- **Vagrant**: crea y configura las máquinas virtuales.
- **VirtualBox**: ejecuta las máquinas virtuales.
- **Debian 12**: sistema operativo de las tres máquinas.
- **Ansible**: instala y configura los servicios en las máquinas con playbooks.
- **Ansible Vault**: guarda cifrados los hashes de las contraseñas de los usuarios FTP.
- **BIND9**: el programa que hace de servidor DNS.
- **Apache**: el servidor web.
- **vsftpd**: el servidor FTP.
- **FileZilla**: cliente FTP para hacer las pruebas.
- **Git y GitHub**: guardan los cambios y el historial. Con las issues y GitHub Projects organizo las tareas.

## 3. Cómo ejecutar el proyecto

Para poner en marcha el proyecto hay que tener Vagrant y VirtualBox instalados. Cada máquina usa 2 GB de RAM, así que hacen falta unos 6 GB libres.

Primero se clona el repositorio y se entra en la carpeta del proyecto:

```bash
git clone https://github.com/B-V-C/ftp-vagrant-ansible.git
cd ftp-vagrant-ansible
```

Las contraseñas de los usuarios FTP están cifradas con Ansible Vault en `ftp/vars/vault.yml`. La contraseña del vault no está en el repositorio, así que antes de arrancar hay que crear en la raíz del proyecto un fichero `vault_pass.txt` que contenga solo esa contraseña. En PowerShell se puede crear así, cambiando `CONTRASEÑA` por la del vault:

```bash
Set-Content -Path vault_pass.txt -Value "CONTRASEÑA" -NoNewline
```

Después se ejecuta:

```bash
vagrant up
```

Vagrant crea las tres máquinas. En la máquina `ansible` ejecuta el script `script/ansible.sh`, que instala Ansible, copia los ficheros y lanza los tres playbooks: DNS, web y FTP. Al terminar, todo queda instalado y funcionando sin hacer nada más.

Para comprobarlo:

```bash
vagrant ssh dns -c "bash /vagrant/dns/test-dns.sh"
```

```bash
vagrant ssh ansible -c "bash /vagrant/web/test-web.sh"
```

Para usar los nombres `www.borja.test` y `ftp.borja.test` desde el ordenador, hay que poner `192.168.57.5` como servidor DNS. En [la documentación](doc/README.md) está explicado cómo lo hice en Windows.

Para volver a lanzar el script y los playbooks:

```bash
vagrant provision ansible
```

Para ver el estado de las máquinas:

```bash
vagrant status
```

Para detenerlas:

```bash
vagrant halt
```

Para eliminarlas:

```bash
vagrant destroy -f
```

La documentación de todo el proceso, con las capturas y los problemas que me encontré, está en [doc/README.md](doc/README.md).

## 4. Licencia

Este proyecto está bajo la licencia GNU General Public License v3.0. La elegí porque es la misma que usa Ansible y porque obliga a que las versiones modificadas sigan siendo libres.
