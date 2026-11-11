# FTP con Vagrant y Ansible paso a paso

Autor: Borja Valdearenas Cano

## 1. Introducción

En esta práctica monto tres máquinas virtuales con Vagrant (`dns`, `ansible` y `negocio`) y las configuro con Ansible. La máquina `ansible` es el nodo de control: desde ella se lanzan los playbooks que instalan el DNS en `dns` y el servidor web y el FTP seguro en `negocio`.

En este documento voy contando cada paso con sus comprobaciones. El objetivo, las herramientas y cómo arrancar el proyecto están en el [README principal](../README.md).

## 2. GitHub y gestión del proyecto

Creé el repositorio `ftp-vagrant-ansible` en GitHub y añadí al profesor (`frayaIzv`) como colaborador.

Para organizar el trabajo creé un proyecto en GitHub Projects con un tablero de tres columnas: **Por hacer**, **En progreso** y **Hecho**. Las columnas salen en inglés por defecto, así que les cambié el nombre y la descripción. Puse el proyecto público, porque los proyectos tienen permisos aparte del repositorio y así el profesor lo puede ver.

Después creé las issues del enunciado: 7 principales con 33 sub-issues, 40 en total. Cada una tiene el objetivo y la comprobación en la descripción, está asignada a mí y está añadida al tablero.

![Tablero del proyecto con las issues](img/01-tablero.png)

Cuando empiezo una tarea muevo su issue a **En progreso**. Al terminarla, pongo `Closes #N` en el mensaje del commit. GitHub la cierra sola al llegar el commit a `main`, y el tablero la pasa a **Hecho**. Si un commit resuelve varias issues hay que repetir `Closes` delante de cada número (`Closes #3, Closes #4`); si pones `Closes #3, #4` solo se cierra la primera.

## 3. Licencia

Añadí el fichero `LICENSE` desde GitHub con **Add file → Create new file**. Al escribir `LICENSE` como nombre sale el botón **Choose a license template**, que mete el texto completo de la licencia.

Elegí la **GNU GPL v3.0**, que es la misma que usa Ansible. Permite usar y modificar el proyecto, pero obliga a que las versiones modificadas que se distribuyan sigan siendo libres. GitHub la reconoce y la muestra en el apartado **About** del repositorio.

Commit: `Añadida licencia GPLv3 (Closes #1)`. Como lo hice en la web, luego hice `git pull` para tenerlo en mi ordenador.

## 4. README

El `README.md` de la raíz lo hice en tres commits, uno por cada parte, para cerrar cada sub-issue con su commit:

1. Título, autor e introducción (`Closes #3, Closes #4`).
2. Herramientas (`Closes #5`).
3. Cómo ejecutar el proyecto y licencia (`Closes #6, Closes #2`). Con este último cerré también la issue principal.

## 5. Vagrant

### 5.1. Fichero `.gitignore`

Antes de crear las máquinas añadí un `.gitignore` con la carpeta `.vagrant/`. Vagrant la crea al hacer `vagrant up` y dentro guarda las claves privadas de las máquinas, que no se deben subir al repositorio.

```text
# Carpeta de Vagrant con las máquinas y sus claves privadas
.vagrant/
```

Al hacer `git add` me salió este aviso:

```text
warning: in the working copy of '.gitignore', CRLF will be replaced by LF the next time Git touches it
```

No es un error. VS Code guardaba los ficheros con finales de línea de Windows (`CRLF`) y Git los guarda en el repositorio con los de Linux (`LF`). El problema es que Vagrant usa los ficheros de mi carpeta, no los del repositorio, y los ficheros que se copian a las máquinas Debian pueden dar problemas con `CRLF`. Para evitarlo cambié en VS Code la opción **Files: Eol** a `\n`, y así los ficheros nuevos se crean con `LF`.

### 5.2. Script `script/ansible.sh`

Este script prepara la máquina `ansible` como nodo de control. Lo ejecuta Vagrant solo en esa máquina:

- Instala `ansible`, `ansible-lint` y `whois` (este último trae `mkpasswd`, que usaré para las contraseñas del FTP).
- Copia las claves privadas de `dns` y `negocio` desde `/vagrant/.vagrant/...` a `private_keys/` y les pone permisos `600`. Si se usan directamente desde la carpeta compartida con Windows, salen con permisos abiertos y SSH se niega a usarlas.
- Copia los ficheros de Ansible y lanza los playbooks.

Como al principio no existen todos los ficheros, las líneas que los copian están comentadas. Las voy descomentando según los creo. Si no, el script fallaría al intentar copiar algo que no existe, porque empieza con `set -xeu`: `-e` para el script en el primer error, `-u` da error con variables sin definir y `-x` muestra cada comando antes de ejecutarlo.

Commit: `Añadido script/ansible.sh para preparar el nodo de control (Closes #12)`.

### 5.3. Fichero `requirements.yml`

Lista las colecciones de Ansible que necesita el proyecto. Solo hay una, `community.crypto`, que trae los módulos para crear el certificado del FTP:

```yaml
---
collections:
  - name: community.crypto
```

Commit: `Añadido requirements.yml con la colección community.crypto (Closes #13)`.

Después descomenté en `ansible.sh` las dos líneas que lo usan: la que lo copia y la que instala las colecciones con `ansible-galaxy collection install -r requirements.yml`.

### 5.4. Fichero `Vagrantfile`

Define las tres máquinas con la imagen `debian/bookworm64` en la red privada `192.168.57.0/24`:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"

  config.vm.define "dns" do |dns|
    dns.vm.hostname = "dns.borja.test"
    dns.vm.network "private_network", ip: "192.168.57.5"
  end

  config.vm.define "negocio" do |negocio|
    negocio.vm.hostname = "negocio.borja.test"
    negocio.vm.network "private_network", ip: "192.168.57.7"
  end

  config.vm.define "ansible" do |ansible|
    ansible.vm.hostname = "ansible.borja.test"
    ansible.vm.network "private_network", ip: "192.168.57.6"
    ansible.vm.provision "shell", path: "script/ansible.sh"
  end
end
```

La máquina `ansible` va la última porque Vagrant crea las máquinas en orden, y su script copia las claves de `dns` y `negocio`. Si se creara antes, esas claves todavía no existirían.

La primera vez que hice `vagrant up` me salió esto:

```text
A Vagrant environment or target machine is required to run this
command. Run `vagrant init` to create a new Vagrant environment.
```

Había escrito mal el nombre del fichero. Tiene que llamarse exactamente `Vagrantfile`, con la `V` mayúscula y sin extensión. Lo renombré y ya funcionó.

### 5.5. Comprobaciones

Con `vagrant up` se crean las tres máquinas. En la salida se ve cómo el script instala Ansible, copia las claves e instala `community.crypto`.

```bash
vagrant status
```

![Estado de las máquinas](img/02-vagrant-status.png)

Salen las tres máquinas en `running`. En el enunciado pone que "deben aparecer las dos máquinas", pero son tres.

Para comprobar el nombre y la IP de cada máquina lanzo un comando en cada una sin entrar en ellas:

```bash
vagrant ssh dns -c "hostname -f; ip -4 -br addr show eth1"
```

```bash
vagrant ssh negocio -c "hostname -f; ip -4 -br addr show eth1"
```

```bash
vagrant ssh ansible -c "hostname -f; ip -4 -br addr show eth1"
```

![Nombre e IP de cada máquina](img/03-nombres-ips.png)

Cada una tiene su nombre completo y su IP en `eth1`, la tarjeta de la red privada: `dns.borja.test` con `192.168.57.5`, `negocio.borja.test` con `192.168.57.7` y `ansible.borja.test` con `192.168.57.6`.

Commit: `Añadido Vagrantfile con las máquinas dns, negocio y ansible (Closes #8, Closes #9, Closes #10, Closes #11, Closes #7)`.
