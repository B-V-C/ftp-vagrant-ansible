# FTP con Vagrant y Ansible

Autor: Borja Valdearenas Cano

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

Para poner en marcha el proyecto hay que tener Vagrant y VirtualBox instalados.

Primero se clona el repositorio y se entra en la carpeta del proyecto:

```bash
git clone https://github.com/B-V-C/ftp-vagrant-ansible.git
cd ftp-vagrant-ansible
```

Después se ejecuta:

```bash
vagrant up
```

Vagrant crea las tres máquinas. En la máquina `ansible` ejecuta además el script `script/ansible.sh`, que instala Ansible y la deja preparada para configurar las otras dos.

Para ver el estado de las máquinas:

```bash
vagrant status
```

Para entrar en el nodo de control:

```bash
vagrant ssh ansible
```

Para detener las máquinas:

```bash
vagrant halt
```

Para eliminarlas:

```bash
vagrant destroy -f
```

## 4. Licencia

Este proyecto está bajo la licencia GNU General Public License v3.0. La elegí porque es la misma que usa Ansible y porque obliga a que las versiones modificadas sigan siendo libres.
