# Soluciones comentadas — Clase 14

> Mirá esto **después** de intentarlo. El valor está en el error, no en la respuesta.
> Y ojo: la solución del 🏁 **reto de la bandera no está acá** (ni va a estar).

---

## 1. Tu primer playbook

```yaml
---
- name: Hola Ansible
  hosts: localhost
  gather_facts: true
  tasks:
    - name: Mostrar quien soy
      ansible.builtin.debug:
        msg: "Distro: {{ ansible_distribution }} · Familia: {{ ansible_os_family }}"

    - name: Asegurar el directorio de configuracion
      ansible.builtin.file:
        path: "{{ ansible_env.HOME }}/lab-ansible/banco/etc"
        state: directory
        mode: "0755"
```

**La diferencia:** 1ª corrida `changed=1`, 2ª corrida `changed=0`. El `debug` siempre
dice `ok` (no modifica nada); el `file` solo dice `changed` la primera vez, cuando el
directorio no existía. Eso es idempotencia en tres líneas.

---

## 2. Idempotencia: el experimento

El script te deja:

```
servidor=10.0.10.20
servidor=10.0.10.20
servidor=10.0.10.20
```

Porque `>>` **agrega**. No pregunta, no compara: agrega. Es una **instrucción**.

El playbook:

```yaml
- name: Registrar el servidor una sola vez
  ansible.builtin.lineinfile:
    path: "{{ ansible_env.HOME }}/lab-ansible/banco/etc/app.conf"
    line: "servidor=10.0.10.20"
    state: present
    create: true
```

Te deja **una** línea, corras las veces que corras. Porque es un **estado deseado**:
"quiero que esta línea esté". `lineinfile` primero **mira** si está y después decide.

La frase para llevarse: **el script dice cómo hacerlo; el playbook dice cómo tiene
que quedar.**

---

## 3. De `command` a módulo

1. La segunda corrida dice `changed` igual. `mkdir -p` no falla si ya existe, pero
   Ansible **no puede saberlo**: ejecutó un comando externo y no tiene forma de
   comparar contra nada. Ante la duda, reporta `changed`.

2. Bien escrito:

   ```yaml
   - name: Asegurar el directorio de datos
     ansible.builtin.file:
       path: "{{ ansible_env.HOME }}/lab-ansible/banco/datos"
       state: directory
       mode: "0755"
   ```

3. Las dos respuestas válidas:

   ```yaml
   # (a) creates: -> "si esto ya existe, ni lo corras"  => queda skipped
   - name: Crear el directorio de datos
     ansible.builtin.command: mkdir -p /ruta/datos
     args:
       creates: /ruta/datos

   # (b) changed_when: -> vos le decis cuando considerar que cambio
   - name: Crear el directorio de datos
     ansible.builtin.command: mkdir -p /ruta/datos
     register: r
     changed_when: false
   ```

   **Cuándo cada una:** `creates:` cuando el comando produce un artefacto concreto
   (un archivo, un directorio) y no tiene sentido repetirlo. `changed_when:` cuando
   el comando **no cambia nada** (una consulta, un `--version`) o cuando podés
   deducir el cambio de su salida
   (`changed_when: "'ya existe' not in r.stdout"`).

   Igual: **si hay módulo, usá el módulo.** Las dos de arriba son parches.

---

## 4. Plantilla Jinja2

```yaml
---
- name: Configurar la app desde una plantilla
  hosts: localhost
  vars:
    puerto_app: 8080
    entorno: produccion
  tasks:
    - name: Renderizar la configuracion
      ansible.builtin.template:
        src: plantillas/app.conf.j2
        dest: "{{ ansible_env.HOME }}/lab-ansible/banco/etc/app.conf"
        mode: "0640"
```

1. Sí: `changed=0` en la segunda. El `template` compara el resultado **renderizado**
   con lo que hay en disco. Si es igual, no escribe.
2. El `--diff` te muestra `-listen = 8080` / `+listen = 9090`. Sin tocar nada.
   Esa es tu red de seguridad antes de aplicar en producción.
3. Con la fecha adentro, **cada corrida genera un contenido distinto** → `changed`
   para siempre → el playbook perdió la idempotencia y tu `PLAY RECAP` deja de
   servir para detectar desvíos. Por eso `mision.txt.j2` del repo **no lleva fecha**.

---

## 5. Handlers

```yaml
    - name: Renderizar la configuracion
      ansible.builtin.template:
        src: plantillas/app.conf.j2
        dest: "{{ ansible_env.HOME }}/lab-ansible/banco/etc/app.conf"
        mode: "0640"
      notify: Avisar que cambio la config

  handlers:
    - name: Avisar que cambio la config
      ansible.builtin.debug:
        msg: "Aca reiniciaria el servicio"
```

El handler corrió **una sola vez**: en la corrida donde el `template` reportó
`changed`. En la segunda, la tarea dio `ok`, no notificó nada y el handler ni apareció.

**Por qué importa:** reiniciar un servicio es una **caída**, por más corta que sea.
Reiniciarlo en cada corrida cuando la config no cambió es regalar interrupciones.
El handler es "si cambiaste la config, **entonces** reiniciá".

---

## 6. Menor privilegio

1. Te da `Permission denied` o un error del gestor de paquetes pidiendo privilegios.
2. Correcto:

   ```yaml
   - name: Instalar tree
     ansible.builtin.package:
       name: tree
       state: present
     become: true        # <- solo aca
   ```

   Y corrés con `-K` para que te pida la contraseña de `sudo`.
   **Nunca** la escribas en el playbook, el inventario o una variable versionada.

3. Porque todo el playbook pasa a correr como `root`: un `file:` con una ruta mal
   escrita deja de ser un error tuyo en tu `$HOME` y pasa a ser un problema del
   sistema. Y cualquier cosa que el playbook cree queda con dueño `root` sin que lo
   hayas pedido. **Menor privilegio: el permiso mínimo, en el lugar mínimo.**

---

## 7. Multi-distro

```yaml
---
- name: Instalar la libreria YAML en cualquier distro
  hosts: localhost
  vars:
    paquete_yaml:
      Debian: python3-yaml
      Archlinux: python-yaml
      RedHat: python3-pyyaml
  tasks:
    - name: Mostrar que paquete corresponde
      ansible.builtin.debug:
        msg: "En {{ ansible_os_family }} se llama {{ paquete_yaml[ansible_os_family] }}"

    - name: Instalarlo (sin romper si no puedo escalar)
      block:
        - name: Instalar el paquete
          ansible.builtin.package:
            name: "{{ paquete_yaml[ansible_os_family] }}"
            state: present
          become: true
      rescue:
        - name: Avisar sin cortar el play
          ansible.builtin.debug:
            msg: "No pude instalarlo (sudo?). Instalalo a mano y segui."
```

`package` ya elige el gestor por vos (apt/pacman/dnf). Lo que **no** puede adivinar es
que el paquete se llame distinto en cada familia: eso lo resuelve el diccionario.

---

## 8. Leer el PLAY RECAP

1. Cuatro hosts en el inventario; contestaron tres.
2. `unreachable` = Ansible **ni siquiera pudo conectarse**: SSH caído, host apagado,
   DNS o firewall (C7, C11). **No es culpa del playbook** — ninguna tarea llegó a
   ejecutarse en ese host.
3. Porque en la 1ª corrida el estado deseado **todavía no estaba aplicado**: es lo
   esperado que Ansible tenga que poner cosas. `changed` alto en la 1ª es normal.
4. Un `changed` en la 2ª corrida significa **una** de dos:
   - **el playbook está mal escrito** (casi siempre `command`/`shell` sin
     `changed_when:` ni `creates:`), o
   - **alguien tocó el servidor a mano** → **desvío de configuración**.

   Para distinguirlas: `--check --diff`. Si el diff muestra contenido realmente
   distinto, es drift. Si dice que cambiaría y el contenido es idéntico, sos vos.

---

## 9. Un rol mínimo

`roles/app_demo/defaults/main.yml`:

```yaml
---
puerto_app: 8080
entorno: produccion
```

`roles/app_demo/tasks/main.yml`:

```yaml
---
- name: Renderizar la configuracion
  ansible.builtin.template:
    src: app.conf.j2
    dest: "{{ ansible_env.HOME }}/lab-ansible/banco/etc/app.conf"
    mode: "0640"
  notify: Avisar que cambio la config
```

`roles/app_demo/handlers/main.yml`:

```yaml
---
- name: Avisar que cambio la config
  ansible.builtin.debug:
    msg: "Aca reiniciaria el servicio"
```

Y `sitio.yml` queda de 4 líneas.

**Dos ventajas concretas:**
- **Reutilización**: el mismo rol lo aplicás a `web`, a `staging` y a `produccion`
  cambiando solo las variables. No copiás y pegás tareas.
- **Orden y revisión**: cuando el playbook tiene 300 líneas, nadie lo revisa de
  verdad en un Pull Request. Partido en roles, el cambio se ve acotado y se entiende.
  (Y de paso: las rutas se simplifican, el rol busca sus plantillas solo.)

---

## 10. Seguridad y criterio

1. Las tres (hay más, pero estas son las graves):
   - 🔴 **Contraseña en texto plano** en `vars:`. Si ese archivo va a Git, quedó en
     el historial para siempre. Nunca.
   - 🔴 **`chmod 777`**: se lo das a todo el mundo, incluso a procesos que no tienen
     nada que ver. Va `0640`/`0750` según el caso. **Menor privilegio.**
   - 🔴 **`shell:` en lugar de módulos**: `file:` + `copy:` hacen lo mismo, son
     idempotentes, fijan permisos y funcionan en `--check`. Encima `hosts: all` con
     `become: true` a nivel de play es apuntar a todo con `sudo` por las dudas.
   - (Bonus: la tarea se llama `config`. Cuando falle a las 3 AM vas a leer
     `TASK [config]` y no vas a saber qué estaba haciendo.)

2. **Bóveda (Ansible Vault)**: cifra un archivo de variables dentro del repo; se
   abre con una contraseña o un archivo de clave que **nunca** se commitea. También
   existen gestores de secretos externos que el playbook consulta al vuelo.
   **La regla mínima, uses lo que uses: no commitear nada sensible.** El
   `.gitignore` de este repo ya excluye `*.key`, `*.pem`, `id_*`, `vault_pass*` y `.env`.

3. **Sospechás desvío de configuración**: alguien entró al servidor y lo cambió a
   mano, fuera del proceso, sin registro ni revisión. Lo confirmás corriendo con
   `--check --diff`: te muestra exactamente qué línea difiere. Después mirás quién
   entró (`journalctl`, C10) y **arreglás el proceso**, no solo el archivo.
   Que la idempotencia te avise de esto **es un control de seguridad**.

4. **Tarea única en una sola máquina** = script. Ejemplos: comprimir los logs de
   ayer en tu VM, renombrar 200 archivos una vez, sacar un reporte puntual. Si no lo
   vas a repetir, ni lo vas a versionar, ni lo va a correr otro, montar inventario +
   playbook + roles es sobre-ingeniería. **Sobre-ingeniería también es un error.**

---

## 11. IA con criterio

La tarea correcta es:

```yaml
- name: Asegurar el usuario deploy
  ansible.builtin.user:
    name: deploy
    shell: /bin/bash
    groups: docker
    append: true          # <- sin esto, le SACA los otros grupos
    state: present
  become: true
```

Lo que suele salir mal en las respuestas generadas:

| Síntoma | Por qué importa |
|---|---|
| Se olvida de `append: true` | `groups:` **reemplaza** la lista. Sin `append`, le sacás al usuario todos los otros grupos. Es un clásico de romper producción. |
| Inventa parámetros (`user_shell`, `add_to_group`) | No existen. `ansible-doc ansible.builtin.user` te lo dice en 3 segundos. |
| Se olvida de `become: true` | Crear usuarios necesita privilegios. |
| Usa `command: useradd ...` | Funciona una vez y después falla o miente con `changed`. |

**Conclusión:** la IA te acelera el borrador; la verificación es tuya.
`ansible-doc` + `--check --diff` son dos comandos que no te llevan ni un minuto y te
evitan un incidente.
