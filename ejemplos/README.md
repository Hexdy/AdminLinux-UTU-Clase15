# Ejemplos comentados — Clase 14

Playbooks chiquitos para leer y correr. Todos trabajan **en un sandbox**
(`~/lab-ansible/banco`), contra `localhost`, **sin `sudo`** y sin tocar nada del sistema.

```bash
cd ejemplos
ansible-playbook 01_hola_ansible.yml -i inventario_ejemplo.ini
```

| Archivo | Qué te muestra |
|---|---|
| `01_hola_ansible.yml` | El playbook más chico que hace algo útil: facts + directorios. Corrélo **dos veces**. |
| `02_estado_deseado.yml` | **El ejemplo de la clase.** El mismo objetivo hecho mal (`echo >>`) y hecho bien (`lineinfile`). Corrélo tres veces y compará los dos archivos. |
| `03_handlers.yml` | "Si cambió la config, **entonces** reiniciá". Corrélo dos veces y después con `-e "puerto_app=9090"`. |
| `sitio.yml` + `roles/sitio_web/` | Un **rol** mínimo: el playbook queda en 8 líneas y la lógica se ordena en carpetas. |
| `inventario_ejemplo.ini` | Cómo se ve un inventario, con grupos y `children` comentados. |

## La estructura de un rol (nivel introductorio)

```
roles/
  sitio_web/
     defaults/main.yml     <- valores por defecto (los mas faciles de pisar)
     tasks/main.yml        <- QUE hace el rol
     handlers/main.yml     <- QUE hacer si algo cambio
     templates/app.conf.j2 <- plantillas Jinja2 (el rol las busca solo, por nombre)
```

Hay más carpetas posibles (`files/`, `vars/`, `meta/`), pero con estas cuatro te alcanza
para entender la idea: **cuando el playbook crece, se ordena**.

Ventaja concreta: en `tasks/main.yml` la plantilla se referencia como `app.conf.j2`,
sin ruta. El rol sabe buscarla en su propio `templates/`.

## Probá siempre así

```bash
ansible-playbook <archivo>.yml -i inventario_ejemplo.ini --syntax-check
ansible-playbook <archivo>.yml -i inventario_ejemplo.ini --check --diff
ansible-playbook <archivo>.yml -i inventario_ejemplo.ini
```

Y después **de nuevo**, para ver la idempotencia en el `PLAY RECAP`.

Para limpiar el sandbox cuando termines:

```bash
rm -rf ~/lab-ansible
```
