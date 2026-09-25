# Guía de estudio para el Parcial 2

El simulacro no se hace para sacar un puntaje: se hace para **saber qué
estudiar**. Con la lista de los ítems que erraste en la mano, esta guía te dice
qué abrir.

## Paso 1 — Agrupá tus errores por clase

Al corregir en vivo anotaste, al lado de cada error, la clase a la que
pertenecía. Contá cuántos errores te quedaron en cada una:

| Clase | Ítems del simulacro | Errores tuyos |
|-------|---------------------|---------------|
| 9 — Procesos | 2, 8, 10, 14, 19, 22 | |
| 10 — systemd y journalctl | 3, 9, 15, 17, 20, 23 | |
| 11 — SSH | 1, 7, 13, 21, 27 | |
| 12 — Shell scripting | 4, 5, 11, 16, 24, 25, 28, 29 | |
| 13 — Ansible e IaC | 6, 12, 18, 26, 30 | |

> La Clase 12 tiene **ocho** ítems porque es la más grande del bloque: sube los
> cinco escalones (guardar, decidir, repetir, ordenar, correr solo) y se lleva
> `cron` y los timers adentro.

## Paso 2 — Aplicá la regla

* **0 errores** en una clase → no la toques. Ya está.
* **1 o 2 errores** → releé la [chuleta del bloque](./chuleta_bloque_b.md),
  la sección de esa clase. Con eso alcanza.
* **3 o más errores** → releé el **apunte completo** de esa clase y **rehacé su
  ejercicio**. Ahí hay un concepto que no está asentado, no un despiste.

No hace falta repasar las cinco clases. Repasá donde fallaste: es la diferencia
entre estudiar cuatro horas y estudiar una.

## Paso 3 — Qué leer exactamente

| Si erraste… | Clase | Secciones a releer |
|-------------|-------|--------------------|
| Señales, orden TERM→KILL, zombies y huérfanos | 9 | Señales · Estados de proceso |
| Load average, `wa`, `RSS` vs `VSZ`, `available` | 9 | `top` y load average · Memoria |
| `pgrep` / `pkill`, trabajos en segundo plano | 9 | Buscar y terminar procesos |
| `start` vs `enable`, `disable` vs `mask` | 10 | Ciclo de vida de una unidad |
| `daemon-reload` vs `reload`, dónde va el `.service` | 10 | Unidades y sus directorios |
| `203/EXEC`, leer un `status` | 10 | Diagnóstico de arranque |
| Filtros de `journalctl` | 10 | Leer el journal |
| Host key, `known_hosts` | 11 | Primera conexión y confianza |
| Permisos de `~/.ssh`, `StrictModes` | 11 | Claves y permisos |
| `PermitRootLogin`, puerto, `sshd -t` | 11 | Endurecer el servidor |
| `set -euo pipefail` | 12 | Escalón 1 — Guardar |
| Comillas y *word splitting*, `"$@"` | 12 | Escalón 1 — Guardar |
| `-gt` vs `>`, `[[ ]]`, `case` | 12 | Escalón 2 — Decidir |
| `stdout` vs `stderr`, códigos de salida | 12 | Escalón 1 — Guardar |
| Bucles, glob vs `$(ls)`, el subshell del pipe | 12 | Escalón 3 — Repetir |
| Funciones, `local`, `return` vs `echo` | 12 | Escalón 4 — Ordenar |
| `logger`, los cinco campos de cron y sus trampas, timers | 12 | Escalón 5 — Correr solo |
| Idempotencia, `changed=0` | 13 | Idempotencia |
| `command`/`shell`, módulos | 13 | Módulos |
| Handlers y `notify:` | 13 | Handlers |
| `PLAY RECAP`, `unreachable` | 13 | Leer la salida |

## Estrategia para el día del parcial

1. **Pasada rápida.** Contestá todo lo que sabés seguro y marcá lo dudoso.
   No te trabes: el tiempo se va en dos preguntas difíciles.
2. **Segunda pasada.** Volvé solo a lo marcado, con la cabeza más fría.
3. **En verdadero/falso, buscá el absoluto.** "Siempre", "nunca", "solo",
   "alcanza para garantizar": casi siempre es la pista de un falso.
4. **En múltiple opción, descartá primero.** Hay dos opciones que claramente no
   son. Quedan dos y la decisión es mucho más fácil.
5. **Si una respuesta depende de la distro, el enunciado lo dice.** Si no lo
   dice, no depende de la distro.

## Qué entra y qué no

**Entra:** todo lo de las Clases 9 a 13.

**No entra:** el Bloque A (Clases 1 a 7, ya evaluado en el Parcial 1); temas que
no vimos (expresiones regulares complejas, Ansible Vault, roles de Galaxy,
contenedores); y memorizar de taquito un `.service` completo o un `ansible.cfg`.
Sí entra **entender** qué hace cada directiva que sí vimos.

> **Aviso honesto:** algunas preguntas del simulacro reaparecen tal cual en el
> parcial, pero la mayoría son nuevas sobre los mismos temas, con otros
> escenarios y otros números. Memorizar las 30 respuestas **no alcanza**.
