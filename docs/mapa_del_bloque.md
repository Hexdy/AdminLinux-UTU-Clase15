# Mapa del Bloque B — de un servidor a veinte

Cinco clases, una sola historia: **entra un servidor nuevo al equipo, es viernes
a las 18:00, y vos lo tenés que dejar andando.**

```
   HORA  |  QUE HACES                     |  QUE PREGUNTA RESPONDE
  =======+================================+=============================
  18:00  |  [ C11 ] ssh con clave         |  como entro, y como entro
         |          ed25519 + config      |  sin repartir contrasenas
         |            v                   |
  18:10  |  [ C9 ]  ps / top / uptime     |  que esta corriendo y que
         |          kill -TERM, nice      |  se come la maquina
         |            v                   |
  18:25  |  [ C10 ] systemctl status      |  por que el servicio no
         |          journalctl -u -p err  |  arranca, y que dijo el log
         |            v                   |
  19:00  |  [ C12 ] set -euo pipefail     |  como dejo de repetir a mano
         |          if / [[ ]] / for /    |  los mismos cinco comandos...
         |          funciones / main      |  ...y como hago que corra
         |          logger + cron + timer |  solo todas las noches a las 3
         |            v                   |
  20:00  |  [ C13 ] Ansible: estado       |  y como hago lo mismo en
         |          deseado, idempotencia |  los otros 19 servidores
  =======+================================+=============================
```

**La frase del mapa:** entrás seguro (C11), mirás (C9), leés (C10), lo escribís
**y lo agendás** (C12), lo declarás (C13).

## Por qué en ese orden

El bloque crece sobre dos ejes. Primero en el **tiempo** (que no dependa de que
vos estés despierto), después en la **escala** (que no dependa de cuántas
máquinas haya).

```
   FASE 1: OBSERVAR       FASE 2: AUTOMATIZAR      FASE 3: AUTOMATIZAR
   (a mano, 1 maquina)  > EN EL TIEMPO          >  EN ESCALA
                          (1 maquina, sola)        (N maquinas, declaradas)
   C11 + C9 + C10         C12                      C13
   vos mirando            el script mirando        el repo mandando
```

> **La regla que atraviesa las cinco clases:** si una acción no está escrita en
> algún lado (script, crontab, playbook, repositorio), **no existe**: se pierde
> el viernes que vos no estás.

## Concepto madre de cada clase

| Clase | Concepto madre | La frase para acordarse |
|-------|----------------|-------------------------|
| **9** — Procesos | `kill` no mata: **manda una señal** | TERM pide, KILL arranca de un tirón |
| **10** — systemd | **Unidad** (archivo) ≠ **proceso** (RAM) | `start` es ahora, `enable` es el próximo boot |
| **11** — SSH | Hay **dos** autenticaciones: primero el servidor, después vos | La pública se reparte, la privada no sale nunca |
| **12** — Shell scripting | Un script **decide** mirando códigos de salida, y después **corre solo** | `set -euo pipefail`, comillas siempre, rutas absolutas en cron |
| **13** — Ansible | Se declara el **estado deseado**, no los pasos | La 2.ª corrida tiene que dar `changed=0` |

## El error típico de cada clase

| Clase | Error típico | Qué hacer en su lugar |
|-------|--------------|------------------------|
| 9 | `kill -9` como primer reflejo; `pkill` sin mirar | TERM → esperar → KILL. `pgrep -a` antes de `pkill` |
| 10 | Editar la unidad y no hacer `daemon-reload` | `daemon-reload` y después reiniciar. Editar en `/etc/systemd/system/` |
| 11 | `chmod 777 ~/.ssh` para que "ande" | `700` en `~/.ssh` y `600` en la privada y en `authorized_keys` |
| 12 | Variables sin comillas, sin `set -euo pipefail`, y suponer que cron tiene tu entorno | `"$VAR"`, `"$@"`, encabezado seguro, `shellcheck`; rutas absolutas y `logger` en cron |
| 13 | `command`/`shell` sin `creates:` ni `changed_when:` | Usar el módulo que existe para esa tarea |

## La pregunta que cae seguro

| Clase | Pregunta |
|-------|----------|
| 9 | Load alto con CPU ociosa y `wa` alto: ¿cuál es el cuello de botella? |
| 10 | ¿Cómo se lee un `systemctl status` que falló? ¿Qué es `203/EXEC`? |
| 11 | ¿Por qué `PermitRootLogin no`? |
| 12 | ¿Qué diferencia hay entre `-gt` y `>`? ¿Y qué agenda `0 9 * * 1-5`? |
| 13 | En el `PLAY RECAP`, ¿qué diferencia hay entre `failed` y `unreachable`? |
