# Playbooks de Ansible — AdminLinux Clase 14 (IaC + el reto de la bandera)

El 🏁 reto de hoy es el que cierra el círculo del curso: **el mismo Ansible que
venís corriendo desde la Clase 1 sin entenderlo** es el tema de la clase.

> 🐧 Con una sola VM alcanza: todo corre contra `localhost` (grupo `[local]`).
> No es hacking: es el laburo de heredar un servidor mal documentado y dejarlo
> descrito como código.

## Paso 0 — ¿Tenés todo? (te dice qué falta y cómo instalarlo)

```bash
cd playbooks
bash comprobar_requisitos.sh
```

Detecta tu distro y, si falta algo (Ansible, Python, la librería YAML, gawk),
te da el comando exacto para **apt**, **pacman** o **dnf**.

## Paso 1 — Armá el banco de trabajo

```bash
# Simular primero (no toca nada, buena costumbre):
ansible-playbook armar_reto.yml -l local --check --diff

# Aplicar de verdad (deja datos/reto/ listo):
ansible-playbook armar_reto.yml -l local
#   ↳ si al instalar los paquetes te pide contraseña de sudo, agregá  -K
```

Atajo que hace el preflight + el armado:

```bash
bash correr.sh
```

Leé tu misión:

```bash
cat ../datos/reto/MISION.txt
```

> 💡 Corré `armar_reto.yml` **dos veces**. La 2ª tiene que dar `changed=0`. Ese
> playbook está escrito bien a propósito: es el modelo de lo que te vamos a pedir.

## Paso 2 (Parte A) — Dejá el servidor como código

El playbook heredado (`provisionar_reto.yml`) **anda pero está mal escrito**.
Copialo, arreglalo y probá que la segunda corrida no cambie nada:

```bash
cd ../datos/reto
cp provisionar_reto.yml mi_provisionar.yml
nano mi_provisionar.yml

ansible-playbook mi_provisionar.yml -l local   # 1ª: changed
ansible-playbook mi_provisionar.yml -l local   # 2ª: changed=0  <- el objetivo
```

El **estado deseado** está en [`../docs/estado_deseado.md`](../docs/estado_deseado.md)
y también dentro de tu `MISION.txt`.

Auditá cómo vas (desde `playbooks/`):

```bash
ansible-playbook auditar_idempotencia.yml -l local
```

## Paso 3 (Parte B) — Las 3 respuestas

Todo sale de `../datos/reto/evidencia/`:

1. **R1** — el servidor con **desvío de configuración** (el que reportó más
   `changed` en la **segunda** corrida).
2. **R2** — cuántas tareas del playbook heredado son **no idempotentes**
   (`command`/`shell` sin `changed_when` ni `creates`).
3. **R3** — cuántas veces quedó repetida la línea **exacta** `10.0.10.20 appsrv`
   en `hosts_extra_original`.

Formato: `BANDERA{<R1>-<R2>-<R3>}`.

> 💡 Los comandos exactos NO están acá a propósito: la idea es que los armes vos
> (el apunte te da todas las piezas: leer un PLAY RECAP, `grep -c`, `grep -x`).
> Si le pedís ayuda a una IA, **verificá el número** con una muestra chica antes
> de confiar.

## Paso 4 — Verificá tu bandera con Ansible

```bash
ansible-playbook comprobar_bandera.yml -e "bandera=BANDERA{...}"
```

El verificador tiene **dos puertas**:

| Puerta | Qué mira |
|---|---|
| 1 · idempotencia | Que el servidor haya quedado en el **estado deseado**. Si dejaste el `echo >>`, la línea está duplicada y no abre. |
| 2 · la bandera | Que el **SHA-256** de lo que pasaste coincida con la huella guardada. |

- ✅ correcta → 🏁 trofeo. **Se la decís al profe** (no hay Pull Request).
- ❌ incorrecta → el mensaje te dice qué revisar.

El repo **no guarda la bandera en texto plano**: solo su huella **SHA-256** en
`secretos/bandera.sha256`. Es la misma idea con la que se guardan las contraseñas.
**Security by design.**

## 🔀 Multi-distro: el mismo playbook en 3 familias

| | Debian / Ubuntu | Arch | Fedora / RHEL |
|---|---|---|---|
| Gestor | `apt` | `pacman` | `dnf` |
| Librería YAML | `python3-yaml` | `python-yaml` | `python3-pyyaml` |
| Detección | `ansible_os_family == 'Debian'` | `'Archlinux'` | `'RedHat'` |

El playbook detecta la familia con `ansible_os_family`, el módulo genérico
`package` elige el gestor y un **mapa de nombres** resuelve que el paquete se
llame distinto en cada una. La instalación va dentro de un **`block`/`rescue`**:
si no podés escalar a `sudo`, el playbook **no se rompe**, te avisa y sigue.

## Qué hay acá

| Archivo | Qué es |
|---|---|
| `armar_reto.yml` | Arma el banco de trabajo (idempotente, multi-distro). **Leelo: es el modelo.** |
| `auditar_idempotencia.yml` | Te audita el estado del servidor y tu playbook. No da respuestas. |
| `comprobar_bandera.yml` | Verifica el reto: puerta de idempotencia + bandera por hash. |
| `comprobar_requisitos.sh` | Preflight: detecta tu distro y te dice qué instalar. |
| `correr.sh` | Atajo: preflight + armado. **El que venís corriendo desde la Clase 1.** |
| `templates/mision.txt.j2` | Plantilla Jinja de la misión (se personaliza con tus facts). |
| `plantillas/app.conf.base` | La configuración base del equipo: la fuente de verdad. |
| `reto/provisionar_reto.yml` | El playbook **heredado**. Evidencia, no ejemplo a copiar. |
| `reto/corrida_1.txt` · `reto/corrida_2.txt` | Las dos corridas del legacy. Ahí vive R1. |
| `reto/inventario_reto.ini` | El inventario de la flota heredada. |
| `reto/servidor/` | El servidor desordenado que tenés que arreglar. |
| `reto/nota_equipo.txt` | La nota del equipo (se deja en 0600). Tiene un dato **falso**. |
| `secretos/bandera.sha256` | Solo la **huella** de la bandera (no el secreto). |
| `inventory.ini` / `ansible.cfg` | A quién le habla Ansible + la config local. |

## ⚠️ Seguridad

- Ningún playbook usa `chmod 777`, contraseñas en texto plano ni secretos versionados.
- `become` (sudo) se enciende **solo en la tarea que instala paquetes**, no en todo
  el playbook: menor privilegio.
- La nota con valor queda en **0600**; la evidencia, en **0444** (solo lectura).
- La bandera se guarda como **hash**, no en claro.
- Simulá con `--check --diff` antes de aplicar algo que no conozcas.
- Nada de esto toca `/etc`, ni arranca servicios, ni abre puertos: todo vive
  dentro de `datos/reto/`.
