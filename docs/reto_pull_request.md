# Reto de la semana — Clase 14 🏁 (la bandera)

Cerramos el semestre como se cierra un proyecto real: **heredás un servidor mal
documentado**, lo dejás **descrito como código** (idempotente, en un archivo que
podría vivir en Git) y sacás las conclusiones del incidente. La recompensa es la
**bandera**, y **se la decís al profe**.

> 🤔 Dato: el `./correr.sh` que corrés desde la Clase 1 **es Ansible**. Hoy el reto
> es entender lo que venís usando y escribir el tuyo.

> 🏁 **Este reto NO se entrega por Pull Request.** No tenés que subir nada:
> cuando tengas la bandera verificada, **se la decís al profe** (en clase o por el
> canal del curso). Eso es todo.

> 🔒 Los playbooks **no tocan `/etc`, no levantan servicios y no abren puertos**.
> Todo el escenario vive dentro de `datos/reto/`. Corrélos tranquilo.

## Pasos

1. **Cloná fuera de Drive**:
   ```bash
   git clone <url> C:\src\AdminLinux-UTU-Clase14
   cd C:\src\AdminLinux-UTU-Clase14\playbooks
   ```
2. **Armá el banco de trabajo con Ansible** (idempotente; simulá primero):
   ```bash
   ansible-playbook armar_reto.yml -l local --check --diff
   ansible-playbook armar_reto.yml -l local
   ```
   Corré el playbook **dos veces**: la 2ª da `changed=0`. Eso es idempotencia, y es
   exactamente lo que te vamos a pedir a vos.
3. **Leé la misión y la nota del equipo**:
   ```bash
   cat ../datos/reto/MISION.txt
   cat ../datos/reto/nota_equipo.txt
   ```
   > ⚠️ La nota tiene una bandera **falsa** a propósito. Un compañero te va a decir
   > "de memoria" cuál era. **No le creas**: razonó mal. Sacá vos los números.
4. **Parte A — dejá el servidor como código.** Copiá el playbook heredado,
   reescribilo y probalo hasta que la 2ª corrida dé `changed=0`:
   ```bash
   cd ../datos/reto
   cp provisionar_reto.yml mi_provisionar.yml
   ansible-playbook mi_provisionar.yml -l local   # 1ª: changed
   ansible-playbook mi_provisionar.yml -l local   # 2ª: changed=0
   ```
   El estado deseado está en [`estado_deseado.md`](./estado_deseado.md).
5. **Parte B — las 3 respuestas**, todas sobre `datos/reto/evidencia/`:
   - **R1** — el servidor con **desvío de configuración**: el que reportó más
     tareas `changed` en la **segunda** corrida.
   - **R2** — cuántas tareas del playbook heredado son **no idempotentes**
     (`command`/`shell` **sin** `changed_when:` ni `creates:`).
   - **R3** — cuántas veces quedó repetida la línea **exacta** `10.0.10.20 appsrv`
     en `hosts_extra_original`.
6. **Armá la bandera** con el formato exacto y **verificala** con Ansible:
   ```bash
   ansible-playbook comprobar_bandera.yml -e "bandera=BANDERA{<R1>-<R2>-<R3>}"
   ```
   Tiene que dar **✅ BANDERA CORRECTA**. Ojo: el verificador **primero** revisa que
   el servidor haya quedado en el estado deseado. Sin la Parte A no hay bandera.
7. **Decile la bandera al profe** — en clase o por el canal del curso. Con eso el
   reto queda entregado. **No hace falta subir nada ni abrir un Pull Request.**

## Las tres trampas (avisadas)

- **"El que más cambió" no es el de la primera corrida.** En la 1ª corrida *todos*
  cambian: es lo esperado, están recién provisionados. El **desvío** se ve en la
  **segunda**, cuando ya no tendría que cambiar nada. Mirá el `PLAY RECAP` correcto.
- **El que no contestó no es el culpable.** Hay un host `unreachable`. Eso es un
  problema de red o de SSH (C7, C11), **no** de desvío de configuración. No confundas
  "no pude entrar" con "alguien lo tocó a mano".
- **"Exacta" es exacta.** En el `hosts_extra` hay líneas **parecidas** (otro nombre,
  otro espaciado, comentadas). Si grepeás la IP sola, o el nombre solo, contás de más.
  `grep --help` y buscá qué hace `-x`. Y `-c` para contar.

## Cómo se evalúa (autoevaluación)

- [ ] Corriste `armar_reto.yml` **dos veces** y la 2ª dio `changed=0`.
- [ ] Tu `mi_provisionar.yml` **no usa** `command`/`shell` donde hay un módulo que sirve.
- [ ] La 2ª corrida de **tu** playbook da `changed=0` (esa es la prueba).
- [ ] `app.conf` quedó en `0640` (menor privilegio) y sale de la base del equipo.
- [ ] `hosts_extra` tiene **una sola** línea útil.
- [ ] **R1** sale del `PLAY RECAP` de la **segunda** corrida.
- [ ] **R2** descarta los `command` que **sí** están marcados con `changed_when`/`creates`.
- [ ] **R3** cuenta la línea **exacta**, no la IP suelta.
- [ ] No le creíste a la nota del equipo sin verificar.
- [ ] `comprobar_bandera.yml` te dio la bandera **correcta** (✅).
- [ ] Le **dijiste la bandera al profe**.

> 🔒 El repo no guarda la bandera en claro, solo su **hash SHA-256**. Así se guardan
> las contraseñas de verdad: nunca el secreto, solo su huella.

> 🤖 Si le pedís ayuda a una IA, pedile el comando **y verificá el número** con una
> muestra chica (`head`, `wc -l`) antes de confiar. Y si te inventa un parámetro de
> un módulo, `ansible-doc ansible.builtin.<modulo>` te lo desmiente en 3 segundos.
> **Verificar antes de confiar** — igual que `--check` antes de aplicar.
