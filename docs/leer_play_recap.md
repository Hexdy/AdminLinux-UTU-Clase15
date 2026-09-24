# Cómo se lee una corrida de Ansible (y el PLAY RECAP)

> Esto es lo que vas a mirar el día que algo se rompa a las 3 de la mañana.
> Leerlo bien es una habilidad de trabajo, no un detalle.

## La salida, de arriba a abajo

```
PLAY [Aprovisionar los servidores web] *****************************

TASK [Gathering Facts] *********************************************
ok: [app01]
ok: [app02]

TASK [Instalar el servidor web] ************************************
changed: [app01]
ok: [app02]

TASK [Poner la configuracion del sitio] ****************************
ok: [app01]
changed: [app02]

TASK [Dejar el servicio corriendo] *********************************
ok: [app01]
ok: [app02]

RUNNING HANDLER [Reiniciar el servidor web] ************************
changed: [app02]

PLAY RECAP *********************************************************
app01  : ok=4  changed=1  unreachable=0  failed=0  skipped=0  rescued=0  ignored=0
app02  : ok=4  changed=2  unreachable=0  failed=0  skipped=0  rescued=0  ignored=0
```

Traducción línea por línea:

| Lo que ves | Qué te está diciendo |
|---|---|
| `PLAY [...]` | Arranca un play. El texto es el `name:` que vos escribiste. |
| `TASK [Gathering Facts]` | Ansible se conectó y le preguntó al host quién es (distro, IP, RAM). Por eso podés usar `ansible_os_family`. |
| `ok: [host]` | Esa tarea **ya estaba como pediste**. No tocó nada. |
| `changed: [host]` | **Modificó** algo en ese host. |
| `RUNNING HANDLER [...]` | Un handler se disparó porque **alguna tarea lo notificó**. Fijate que solo corrió para `app02`: es el único donde cambió la config. |
| `PLAY RECAP` | El resumen por host. **Es lo primero que mira un profesional.** |

> 💡 Los `TASK [...]` muestran **el nombre que vos pusiste**. Por eso nombrar las
> tareas en castellano y con sentido no es cosmético: es el mensaje de error que
> vas a leer cuando algo falle.

## Los 7 números del PLAY RECAP

| Columna | Qué cuenta | Cuándo te preocupa |
|---|---|---|
| `ok` | Tareas que ya estaban bien (incluye las `changed`). | Nunca. |
| `changed` | Tareas que **modificaron** el host. | En la **2ª corrida**, si no es 0. |
| `unreachable` | No se pudo ni conectar (SSH caído, host apagado, DNS). | Siempre. No es culpa del playbook. |
| `failed` | Se conectó pero la tarea falló. | Siempre. Leé el mensaje. |
| `skipped` | Un `when:` dio falso y la saltó. | Casi nunca. |
| `rescued` | Falló dentro de un `block:` y el `rescue:` la atajó. | Miralo: algo no salió como esperabas. |
| `ignored` | Falló y le dijiste `ignore_errors: true`. | Si lo ves seguido, algo estás tapando. |

## La regla de oro: la segunda corrida

```
  1ra corrida                        2da corrida
+---------------------+            +---------------------+
| ok=4  changed=3     |            | ok=4  changed=0     |
|                     |            |                     |
| puso lo que faltaba |  -------\  | ya estaba todo      |
| (es lo esperado)    |  -------/  | (no toco nada)      |
+---------------------+            +---------------------+
        NORMAL                           IDEMPOTENTE  ✅
```

Si la **segunda** corrida te sigue diciendo `changed`, pasa **una** de dos cosas:

1. **Tu playbook está mal escrito** — casi siempre un `command`/`shell` sin
   `changed_when:` ni `creates:`, que reporta `changed` aunque no haya hecho nada.
2. **Alguien tocó el servidor a mano** — eso es **desvío de configuración**, y
   detectarlo es un **control de seguridad**: significa que hubo un cambio fuera
   del proceso, sin revisión ni registro.

Distinguir 1 de 2 es el trabajo. Truco: corré con `--check --diff`. Si el `--diff`
te muestra un contenido **realmente distinto**, es drift (caso 2). Si te dice que
cambiaría y el contenido es **idéntico**, es tu playbook (caso 1).

## Cuando algo falla

```
TASK [Poner la configuracion del sitio] ****************************
fatal: [app03]: FAILED! => {"changed": false, "msg": "Destination
        directory /opt/app/etc does not exist"}
```

Receta de 4 pasos:

1. **Leé el `msg:`.** El 80% de las veces te dice exactamente qué falta.
2. **Mirá el nombre de la TASK.** Sabés qué estabas intentando hacer.
3. **Mirá el host.** ¿Falla en todos o en uno solo? Si es uno solo, el problema
   es del host, no del playbook.
4. **Repetí con `-v`** (o `-vv`) para ver el comando real y los parámetros.

Los 4 errores que vas a ver mil veces:

| Mensaje (resumido) | Qué pasó |
|---|---|
| `Destination directory ... does not exist` | Te falta una tarea `file: state=directory` **antes**. |
| `Permission denied` | Te falta `become: true` en **esa** tarea (no en todo el playbook). |
| `Missing sudo password` | Corré con `-K` para que te la pida. **Nunca** la pongas en un archivo. |
| `UNREACHABLE! ... Connection refused` | No es Ansible: es SSH/red (C7 y C11). Probá `ssh usuario@host` a mano. |

## `--check`: el simulacro

```bash
ansible-playbook sitio.yml --check --diff
```

`--check` le dice a Ansible: **"decime qué harías, pero no lo hagas"**. Con
`--diff` encima, te muestra el antes/después de cada archivo.

Es tu red de seguridad. Costumbre profesional: **simulá, leé, y recién ahí aplicá.**

⚠️ Un `command`/`shell` sin `check_mode: false` puede reportar `skipped` en modo
simulación. Es normal: Ansible no puede adivinar qué hace un comando arbitrario.
Una razón más para usar módulos de verdad.
