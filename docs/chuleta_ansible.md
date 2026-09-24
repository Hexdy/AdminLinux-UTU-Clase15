# Chuleta — los módulos de Ansible que de verdad vas a usar

> Un **módulo** es la unidad de trabajo de Ansible: un programita que sabe hacer
> **una** cosa y dejarla en el **estado que vos pediste**. Vos no decís "instalá";
> decís "**quiero que esté instalado**". Si ya está, no hace nada (`ok`).
> Si falta, lo pone (`changed`). Eso es **idempotencia**.

Los nombres largos (`ansible.builtin.copy`) son los oficiales. El corto (`copy`)
funciona igual; en material serio se escribe el largo para que no haya ambigüedad.

---

## Los 8 que te alcanzan para el 90% del laburo

| Módulo | Qué hace, en una frase | Parámetro que más vas a usar |
|---|---|---|
| `ansible.builtin.package` | Instala/saca paquetes **sin importar la distro** (elige apt/pacman/dnf por vos). | `name`, `state: present` |
| `ansible.builtin.copy` | Pone un archivo (o un texto) en su lugar, con dueño y permisos. | `src`/`content`, `dest`, `mode` |
| `ansible.builtin.template` | Igual que `copy`, pero primero **rellena una plantilla Jinja2** con variables. | `src` (`.j2`), `dest`, `mode` |
| `ansible.builtin.file` | Se asegura de que un directorio / archivo / enlace **exista** (o no) con ciertos permisos. | `path`, `state: directory`, `mode` |
| `ansible.builtin.lineinfile` | Garantiza que **una línea esté (o no esté)** en un archivo. Sin duplicar. | `path`, `line`, `state: present` |
| `ansible.builtin.service` | Deja un servicio arrancado/parado y habilitado al boot (systemd por debajo, C10). | `name`, `state: started`, `enabled: true` |
| `ansible.builtin.user` | Deja un usuario creado con sus grupos y su shell (C2). | `name`, `groups`, `shell` |
| `ansible.builtin.stat` | **Mira** un archivo y te devuelve si existe, su modo, su tamaño. No cambia nada. | `path` + `register` |

### Los dos de emergencia (y por qué son peligrosos)

| Módulo | Qué hace | La letra chica |
|---|---|---|
| `ansible.builtin.command` | Corre un comando **sin shell** (no hay `>`, `|`, `*`). | Ansible **no sabe** si cambió algo: dice `changed` **siempre**. |
| `ansible.builtin.shell` | Corre un comando **con shell** (sí hay tuberías y redirecciones). | Lo mismo, y encima con los riesgos del shell. |

Regla profesional: **si existe un módulo que hace lo que querés, usá el módulo.**
`command`/`shell` son el último recurso. Y cuando no te queda otra, **marcalos**:

```yaml
- name: Generar el reporte solo si todavía no está
  ansible.builtin.command: /usr/local/bin/generar_reporte
  args:
    creates: /var/lib/app/reporte.txt      # si ese archivo existe -> ni lo corre (skipped)

- name: Consultar la versión (esto NO cambia nada)
  ansible.builtin.command: myapp --version
  register: version_app
  changed_when: false                      # "te juro que esto no modifica nada"
```

`creates:` y `changed_when:` son **las dos formas de devolverle la verdad a Ansible**.
Un `command`/`shell` sin ninguna de las dos es una tarea **no idempotente**: va a decir
`changed` toda la vida y te va a arruinar el `PLAY RECAP`.

---

## Copiar y pegar: el patrón de cada uno

```yaml
# Paquete (funciona en Debian, Arch y Fedora sin cambiar nada)
- name: Instalar el servidor web
  ansible.builtin.package:
    name: nginx
    state: present
  become: true                     # sudo SOLO acá

# Directorio
- name: Asegurar el directorio de logs
  ansible.builtin.file:
    path: /opt/app/logs
    state: directory
    mode: "0755"

# Archivo con contenido fijo
- name: Poner la config base
  ansible.builtin.copy:
    src: app.conf.base
    dest: /opt/app/app.conf
    mode: "0640"                   # menor privilegio, no 0777

# Archivo con plantilla (variables adentro)
- name: Poner la config personalizada
  ansible.builtin.template:
    src: app.conf.j2
    dest: /opt/app/app.conf
    mode: "0640"
  notify: Reiniciar la app        # dispara el handler SOLO si cambió

# Una línea, sin duplicarla nunca
- name: Registrar el host de la app
  ansible.builtin.lineinfile:
    path: /opt/app/hosts_extra
    line: "10.0.10.20 appsrv"
    state: present
    create: true

# Servicio
- name: Dejar la app corriendo y habilitada
  ansible.builtin.service:
    name: miapp
    state: started
    enabled: true
  become: true
```

Y el **handler** que escucha ese `notify:`:

```yaml
  handlers:
    - name: Reiniciar la app
      ansible.builtin.service:
        name: miapp
        state: restarted
      become: true
```

> El handler corre **al final del play** y **solo si alguna tarea lo notificó**.
> Si la config no cambió, el servicio **no se reinicia**. Eso son segundos de
> caída que no le regalás a nadie.

---

## Variables y plantillas Jinja2, lo mínimo

```yaml
  vars:
    puerto_app: 8080
    entorno: produccion
```

En la plantilla `.j2`:

```
listen = {{ puerto_app }}
modo   = {{ entorno }}
{% if entorno == 'produccion' %}
debug  = off
{% endif %}
```

Los **facts** (`ansible_hostname`, `ansible_os_family`, `ansible_distribution`) son
variables que Ansible descubre solo con *Gathering Facts*. Vos las usás igual.

---

## Banderas de la línea de comandos que valen oro

| Bandera | Qué hace |
|---|---|
| `--check` | **Simulacro.** "Decime qué harías, pero no lo hagas." Tu red de seguridad. |
| `--diff` | Te muestra el **antes y después** de cada archivo que tocaría. |
| `-l grupo` | Limita el play a un host o grupo del inventario. |
| `-v` / `-vv` | Más detalle cuando algo falla y no entendés por qué. |
| `-K` | Te pide la contraseña de `sudo` (no la escribas en ningún archivo). |
| `--syntax-check` | Solo revisa que el YAML y la estructura estén bien. No conecta a nada. |

Costumbre de la casa: **`--check --diff` primero, aplicar después.**

---

## El error de YAML que vas a cometer (y cómo lo ves)

YAML se indenta con **espacios**, nunca con tabuladores, y la cantidad importa.

```yaml
- name: Mal indentado
ansible.builtin.file:        # <- ESTO explota: el módulo va indentado bajo el name
    path: /tmp/x
```

Si `ansible-playbook` te tira algo con la palabra `mapping values are not allowed`
o `could not find expected ':'`, es **indentación**. Mirá la línea que te dice y
la de arriba.
