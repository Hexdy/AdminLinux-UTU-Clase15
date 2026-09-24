# AdminLinux UTU — Clase 14 🤖 Ansible e Infraestructura como Código

Repo de práctica de la **Clase 14** de *Administración de Sistemas Linux* (UTU).
Tema: **automatizar de verdad** — dejar la configuración de un servidor **escrita en un
archivo** que se versiona, se revisa y se vuelve a aplicar sin romper nada.

> 🤔 **Spoiler de la clase**: el `./correr.sh` que venís corriendo desde la Clase 1
> **es Ansible**. Hoy vas a entender qué carajo hacía. Y vas a escribir el tuyo.

---

## 🏁 El reto de hoy (empezalo ya, mientras escuchás)

Heredaste una flota de servidores que provisionaba **un compañero que ya no está**. Te
dejó un playbook que "anda", pero la segunda corrida sigue diciendo `changed`. Algo está
mal — o alguien tocó un servidor a mano.

1. **Cloná** el repo (fuera de Drive) y armá el banco de trabajo con Ansible.
2. **Parte A** — reescribí el playbook heredado hasta que la **2ª corrida dé `changed=0`**.
3. **Parte B** — sacá **3 respuestas** de la evidencia y armá la bandera.
4. **Verificá** con `comprobar_bandera.yml` y **decile la bandera al profe**. 🏁

> **La idempotencia es la condición de victoria**: si tu playbook no es idempotente, el
> verificador **no te abre la primera puerta**. No alcanza con adivinar los números.

```bash
git clone <url> C:\src\AdminLinux-UTU-Clase14
cd C:\src\AdminLinux-UTU-Clase14\playbooks
bash comprobar_requisitos.sh          # ¿tenés Ansible? te dice cómo instalarlo
ansible-playbook armar_reto.yml -l local --check --diff   # simular
ansible-playbook armar_reto.yml -l local                  # aplicar
cat ../datos/reto/MISION.txt
```

La guía completa: **[`docs/reto_pull_request.md`](./docs/reto_pull_request.md)**.
El estado deseado: **[`docs/estado_deseado.md`](./docs/estado_deseado.md)**.

> 🏁 Este reto **no se entrega por Pull Request**: cuando el verificador te dé el tilde
> verde, **se la decís al profe** (en clase o por el canal del curso).

---

## 🗺️ Qué hay acá

| Carpeta | Qué encontrás |
|---|---|
| [`ejemplos/`](./ejemplos/) | Playbooks chiquitos y comentados: tu primer playbook, el mismo objetivo **mal y bien**, handlers, y un **rol** mínimo. |
| [`ejercicios/`](./ejercicios/) | 11 ejercicios + soluciones comentadas. |
| [`docs/`](./docs/) | Chuleta de módulos, glosario de IaC, cómo leer un `PLAY RECAP`, el estado deseado y la guía del reto. |
| [`playbooks/`](./playbooks/) | 🏁 El reto: el escenario, la evidencia, el auditor y el verificador por hash. |
| [`CONTEXTO_IA.md`](./CONTEXTO_IA.md) | Resumen para pegarle a una IA cuando le pidas ayuda. |

### Para arrancar

1. **[`docs/glosario_iac.md`](./docs/glosario_iac.md)** — las palabras, en criollo.
2. **[`docs/chuleta_ansible.md`](./docs/chuleta_ansible.md)** — los 8 módulos que te alcanzan.
3. **[`ejemplos/02_estado_deseado.yml`](./ejemplos/02_estado_deseado.yml)** — corrélo tres
   veces y mirá los dos archivos que deja. Ahí se entiende todo.
4. **[`docs/leer_play_recap.md`](./docs/leer_play_recap.md)** — leer la salida como un profesional.

---

## 🧠 Lo mínimo para no perderte

| Idea | En una frase |
|---|---|
| **IaC** | La configuración del servidor escrita en un archivo, versionada en Git. La receta, no la memoria del cocinero. |
| **Estado deseado** | Describís **cómo tiene que quedar**, no los pasos. |
| **Idempotencia** | Correrlo 1 o 5 veces da lo mismo. El botón del ascensor. |
| **Sin agente** | No instalás nada en el servidor destino: Ansible entra **por SSH** (C11). |
| **Inventario** | A quién le hablo. |
| **Módulo** | La unidad de trabajo (`package`, `copy`, `file`, `service`, `lineinfile`, `user`). |
| **Playbook** | La receta completa, en YAML. |
| **Handler** | "Si cambiaste la config, **entonces** reiniciá." |
| **Rol** | El playbook ordenado en carpetas, reutilizable. |
| **`--check`** | El simulacro: "decime qué harías, pero no lo hagas". |

La regla que resume la clase:

```
   1ra corrida                       2da corrida
 +-------------------+             +-------------------+
 | changed=3  ok=5   |  -------\   | changed=0  ok=8   |
 | puso lo que falta |  -------/   | no toco nada      |
 +-------------------+             +-------------------+
       NORMAL                        IDEMPOTENTE  ✅
```

Si la **segunda** corrida te dice `changed`, o tu playbook está mal escrito, o
**alguien tocó el servidor a mano** (desvío de configuración). Las dos cosas
importan. La segunda es un hallazgo de **seguridad**.

---

## 🔒 Seguridad por diseño (lo que se mira en una revisión real)

- 🔴 **Ningún secreto en el repo.** Ni una contraseña, ni un token, ni una clave
  privada. Si necesitás un dato sensible: **bóveda** (Ansible Vault) o un gestor de
  secretos externo. Para `sudo`, `-K` (te la pide y no queda escrita).
- 🔴 **Menor privilegio**: `become: true` **solo en la tarea que lo necesita**, nunca a
  nivel de play "por las dudas".
- 🔴 **Permisos concretos**: `0640`, `0750`. Nunca `0777`.
- 🔴 **`--check --diff` antes de aplicar** algo que no conocés.
- 🔴 **Revisión por pares**: el playbook está en Git, así que un cambio riesgoso se ve
  en un Pull Request **antes** de tocar producción. Ése es el verdadero superpoder de IaC.
- 🔴 La bandera se guarda **hasheada** (SHA-256), nunca en claro. Igual que las
  contraseñas de verdad.

El `.gitignore` de este repo ya excluye `*.key`, `*.pem`, `id_*`, `vault_pass*` y `.env`.

---

## 🤖 IA con criterio

Un asistente te escribe un playbook en 5 segundos. También te **inventa parámetros que
no existen** con total seguridad. Antes de aplicar cualquier cosa que te sugiera:

```bash
ansible-doc ansible.builtin.copy          # ¿existe ese parámetro? te lo dice offline
ansible-playbook mi.yml --syntax-check    # ¿el YAML está bien?
ansible-playbook mi.yml --check --diff    # ¿qué haría exactamente?
```

**Verificar antes de confiar.** Tres comandos, menos de un minuto, cero incidentes.

---

## 🧩 Autoevaluación (5 preguntas, sin respuestas)

Contestalas **antes** de mirar los docs. Si te trabás, abrí la pista.

### 1️⃣ Cocinar de memoria

Un compañero configuró el servidor de producción a mano, anotó los pasos en un papel y
se fue de la empresa. ¿Qué **tres** problemas concretos tenés ahora que no tendrías si
esa configuración estuviera escrita como código en el repo?

<details><summary>💡 Pista</summary>

Pensá qué pasa cuando (a) necesitás un servidor idéntico mañana, (b) alguien quiere
saber **por qué** está así, y (c) el disco se muere el sábado a la noche. La receta
escrita no solo te dice el cómo: también deja registro de **quién** la cambió y **cuándo**.

</details>

### 2️⃣ El ascensor

Tu compañero dice: *"este playbook es idempotente porque no falla si lo corrés dos
veces"*. Está mezclando dos cosas. ¿Qué es **realmente** ser idempotente, y cuál es la
prueba concreta que mirás en la salida?

<details><summary>💡 Pista</summary>

Apretar el botón del ascensor cinco veces no lo hace venir cinco veces. "No falla" y
"no hace nada porque ya está como pedí" son cosas distintas. La prueba está en una
columna del `PLAY RECAP` de la **segunda** corrida.

</details>

### 3️⃣ El `changed` sospechoso

Un playbook que hace tres meses da siempre `changed=0` hoy te reporta `changed=1` en una
tarea. Nadie tocó el repo. ¿Cuáles son las **dos** explicaciones posibles, cómo las
distinguís, y por qué una de las dos es un hallazgo de **seguridad**?

<details><summary>💡 Pista</summary>

Si el código no cambió, cambió **el servidor**. Hay una bandera de la línea de comandos
que te muestra el antes y el después sin tocar nada: si el contenido es realmente
distinto, alguien escribió ahí sin pasar por el proceso. Eso tiene nombre propio.

</details>

### 4️⃣ El último recurso

Tenés que correr un comando para el que **no** hay módulo. ¿Qué le agregás a la tarea
para que no reporte `changed` en cada corrida? Hay **dos** parámetros válidos: nombralos
y decí cuándo usarías cada uno.

<details><summary>💡 Pista</summary>

Uno sirve cuando el comando **produce un artefacto** (si ya existe, ni lo corras). El
otro sirve cuando vos sabés que el comando **no modifica nada** (una consulta, un
`--version`) o podés deducir el cambio leyendo su salida. Los dos están en la chuleta.

</details>

### 5️⃣ Cuándo NO

Te piden comprimir los logs de ayer, **una sola vez**, en **una sola** máquina, y no se
va a repetir. ¿Montás inventario + playbook + roles? Justificá, y decí a partir de qué
momento sí conviene el playbook.

<details><summary>💡 Pista</summary>

Pensá en tres preguntas: ¿lo voy a **repetir**? ¿lo va a correr **otro**? ¿necesito que
quede **registro** de qué se hizo? Si las tres son "no", la herramienta grande es
sobre-ingeniería — y eso también es un error profesional.

</details>

---

## 🎯 Por qué esta clase importa para trabajar

"Sé Ansible" es de las cosas que más pesan en un CV junior de sistemas. Los puestos que
lo piden por nombre: **administración de sistemas**, **DevOps**, **SRE**, **ingeniería
de plataforma**. Y lo que hiciste hoy — heredar algo mal documentado, dejarlo idempotente
y versionado — es **literalmente** la primera tarea que te van a dar.

De paso vas a escuchar nombrar otras familias de herramientas del ecosistema
(aprovisionamiento de infraestructura, contenedores, canalizaciones de CI/CD). Hay
**varias** opciones en cada una; lo que se transfiere es el concepto, no el producto.

Y el cierre del círculo: **el playbook vive en un repositorio**. Git no era un trámite.
