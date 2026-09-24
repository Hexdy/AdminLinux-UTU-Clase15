# Ejercicios — Clase 14 (Ansible e Infraestructura como Código)

> Todo se hace en tu VM, contra `localhost`, dentro de una carpeta de juego.
> No necesitás otra máquina ni tocar nada del sistema.

Preparate un sandbox:

```bash
mkdir -p ~/lab-ansible/banco && cd ~/lab-ansible
```

Y acordate de la costumbre de la casa: **`--check --diff` primero, aplicar después.**

---

## 1. Tu primer playbook (calentamiento)

Escribí `01_hola.yml` que, sobre `hosts: localhost`:

1. Muestre por pantalla la distribución y la familia del sistema
   (pista: `ansible.builtin.debug` + los facts `ansible_distribution` y `ansible_os_family`).
2. Cree el directorio `~/lab-ansible/banco/etc` con modo `0755`.

Corrélo **dos veces**. ¿Qué diferencia ves en el `PLAY RECAP`? Escribila.

---

## 2. Idempotencia: el experimento que hay que hacer una vez en la vida

Creá `agrega.sh` con una sola línea:

```bash
echo "servidor=10.0.10.20" >> ~/lab-ansible/banco/etc/app.conf
```

Corrélo **tres** veces y mirá el archivo (`cat`). Después escribí `02_estado.yml`
que consiga **lo mismo** pero con `ansible.builtin.lineinfile` (con `create: true`).
Corrélo tres veces y volvé a mirar.

**Contestá en dos líneas:** ¿por qué el script te deja el archivo así y el playbook no?

---

## 3. De `command` a módulo (el corazón del reto)

Esta tarea está mal escrita a propósito:

```yaml
- name: Crear el directorio de datos
  ansible.builtin.command: mkdir -p /home/{{ ansible_user_id }}/lab-ansible/banco/datos
```

1. Corré el playbook dos veces. ¿Qué dice la segunda corrida?
2. Reescribila con el módulo correcto y volvé a correr dos veces.
3. **Bonus:** si por alguna razón tuvieras que dejar el `command`, ¿qué parámetro le
   agregarías para que la segunda corrida **no** diga `changed`? Hay **dos** respuestas
   válidas; nombrá las dos y explicá cuándo usarías cada una.

---

## 4. Plantilla Jinja2 con variables

Armá `plantillas/app.conf.j2`:

```
# generado por Ansible, no editar a mano
listen = {{ puerto_app }}
modo   = {{ entorno }}
host   = {{ ansible_hostname }}
```

Y un playbook `03_plantilla.yml` con `vars:` (`puerto_app: 8080`, `entorno: produccion`)
que la renderice a `~/lab-ansible/banco/etc/app.conf` con modo `0640`.

1. Corrélo dos veces. ¿Da `changed=0` la segunda?
2. Cambiá `puerto_app` a `9090` y corré con `--check --diff`. ¿Qué te muestra el `--diff`?
3. **Trampa a propósito:** agregale a la plantilla una línea con la fecha
   (`{{ ansible_date_time.iso8601 }}`), corré dos veces y mirá el `PLAY RECAP`.
   ¿Qué rompiste? Sacala después.

---

## 5. Handlers: reiniciar solo cuando hace falta

Ampliá `03_plantilla.yml`:

- Agregale `notify: Avisar que cambio la config` a la tarea del `template`.
- Agregá un bloque `handlers:` con esa tarea, que solo haga un `debug` con el mensaje
  `"Aca reiniciaria el servicio"`.

Corrélo dos veces seguidas y después cambiando una variable. **Contestá:** ¿cuántas
veces corrió el handler y por qué no corre siempre?

---

## 6. Menor privilegio

Escribí un playbook que instale el paquete `tree` usando `ansible.builtin.package`.

1. Corrélo **sin** `become`. ¿Qué error te da?
2. Poné `become: true` **solo en esa tarea** (no a nivel del play) y corré con `-K`.
3. **Contestá:** ¿por qué está mal poner `become: true` arriba de todo "por las dudas"?

---

## 7. Multi-distro sin `if` a mano

Escribí un playbook que muestre el **nombre correcto del paquete de la librería YAML
de Python** según la familia del sistema, usando un diccionario de variables:

```yaml
  vars:
    paquete_yaml:
      Debian: python3-yaml
      Archlinux: python-yaml
      RedHat: python3-pyyaml
```

Pista: `{{ paquete_yaml[ansible_os_family] }}`. Después envolvé la instalación en un
`block:` con `rescue:` que muestre un aviso amigable si no se puede escalar privilegios.

---

## 8. Leer el PLAY RECAP como un profesional

Mirá `playbooks/reto/corrida_1.txt` y `corrida_2.txt` del repo y contestá:

1. ¿Cuántos hosts había en el inventario y cuántos contestaron?
2. ¿Qué significa que uno aparezca como `unreachable`? ¿Es culpa del playbook?
3. ¿Por qué en la primera corrida **todos** los hosts tienen `changed` alto y eso
   **no** es un problema?
4. ¿Qué te dice un `changed` en la **segunda** corrida? Nombrá las **dos** causas posibles.

---

## 9. Un rol mínimo

Convertí tu `03_plantilla.yml` en un rol:

```
roles/
  app_demo/
    defaults/main.yml      <- puerto_app y entorno (valores por defecto)
    tasks/main.yml         <- las tareas
    templates/app.conf.j2  <- la plantilla
    handlers/main.yml      <- el handler
```

Y un `sitio.yml` que lo use:

```yaml
- hosts: localhost
  roles:
    - app_demo
```

**Contestá:** ¿qué ganás al partirlo así? Nombrá dos ventajas concretas.

---

## 10. Seguridad y criterio

1. Un compañero te pasa este playbook. Marcá **tres** cosas mal y explicá cada una:

   ```yaml
   - hosts: all
     become: true
     vars:
       db_password: "sup3rS3cr3t0"
     tasks:
       - name: config
         ansible.builtin.shell: chmod 777 /opt/app && cp app.conf /opt/app/
   ```

2. ¿Qué mecanismo tiene Ansible para guardar datos sensibles **cifrados** dentro del
   repo? ¿Y cuál es la regla mínima aunque no lo uses?
3. Corrés el playbook de producción un lunes y una tarea que siempre daba `ok` ahora da
   `changed`. **¿Qué sospechás y cómo lo confirmás?**
4. ¿En qué caso **no** usarías Ansible y te alcanzaría un script? Dame un ejemplo concreto.

---

## 11. IA con criterio

Pedile a un asistente de IA: *"escribime una tarea de Ansible que se asegure de que el
usuario `deploy` exista con shell `/bin/bash` y pertenezca al grupo `docker`"*.

Después, **antes de correr nada**:

1. Verificá cada parámetro con `ansible-doc ansible.builtin.user`. ¿Existen todos?
2. ¿Le puso `become: true`? ¿Hace falta?
3. Corrélo con `--check --diff` y recién después decidí.

**Contestá:** ¿qué te inventó, si te inventó algo?
