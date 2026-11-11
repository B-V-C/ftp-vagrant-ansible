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
