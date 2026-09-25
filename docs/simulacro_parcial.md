# Simulacro del Parcial 2 — Bloque B (Clases 9 a 13)

**30 ítems: 20 de múltiple opción + 10 de verdadero/falso.**
Mismo formato que el Parcial 2 real.

## Cómo se hace

* **Solo.** Sin compañeros, sin apuntes, sin IA. Con ayuda, el resultado te
  miente y terminás estudiando lo que no era.
* **Cronometrado: 25 minutos.** Poné el timer antes de empezar.
* **Sin nota.** Nadie te va a preguntar cuánto sacaste.
* **Lo que sí importa:** anotá **cuáles** erraste y de qué clase eran. Ese es el
  entregable real.

En múltiple opción hay una sola opción válida. En verdadero/falso respondés
`V` o `F`.

> Cuando la respuesta depende de la distribución, el enunciado lo dice. Las IP
> que aparecen son de documentación (`192.0.2.0/24`, `203.0.113.0/24`).

---

## Parte 1 — Múltiple opción (1 a 20)

**1.** Te conectás a un servidor al que entrás todas las semanas y SSH te muestra
`WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!`. ¿Qué significa y qué hacés?

a) Que se te venció la clave privada: generás una nueva con `ssh-keygen`
b) Que el servidor está caído: reintentás en un rato
c) Que la huella del servidor no coincide con la guardada en `~/.ssh/known_hosts`: no te conectás hasta averiguar por qué cambió
d) Que erraste la contraseña tres veces y el servidor te bloqueó

**2.** Un servicio de base de datos dejó de responder y hay que terminarlo.
¿Cuál es el procedimiento correcto?

a) `kill -9 <pid>` directo, porque es el más rápido y siempre funciona
b) `kill -TERM <pid>`, esperar unos segundos y, solo si sigue vivo, `kill -9 <pid>`
c) `kill -STOP <pid>` y dejarlo pausado hasta el lunes
d) `kill -HUP 1` para que el sistema se reinicie solo

**3.** Arrancaste un servicio con `sudo systemctl start tienda-api` y quedó
andando. A la madrugada reiniciaron el servidor y el servicio no volvió.
¿Qué faltó?

a) `sudo systemctl reload tienda-api`
b) `sudo systemctl mask tienda-api`
c) `journalctl --vacuum-time=7d`
d) `sudo systemctl enable tienda-api`

**4.** En el encabezado de un script tenés `set -euo pipefail`. ¿Qué aporta
específicamente la `u`?

a) Que usar una variable no definida sea un error, en vez de un vacío silencioso
b) Que el script corra siempre como root
c) Que los finales de línea se conviertan de CRLF a LF
d) Que toda la salida se mande a `stderr`

**5.** Tu script de respaldo anda perfecto cuando lo corrés a mano, pero desde el
crontab falla con `command not found`. ¿Cuál es la causa más probable?

a) Al script le falta el permiso de ejecución
b) Cron no puede ejecutar scripts escritos en Bash
c) Cron corre con un `PATH` mínimo: hay que usar rutas absolutas o definir el `PATH` arriba del crontab
d) El `set -euo pipefail` del encabezado corta la ejecución

**6.** Corrés un playbook de Ansible dos veces seguidas sin tocar nada en el
medio. Si el playbook está bien escrito, ¿qué tiene que mostrar el `PLAY RECAP`
de la segunda corrida?

a) `changed=0`
b) Los mismos `changed` que la primera corrida
c) `unreachable=1`
d) `failed=1`

**7.** Copiaste tu clave pública con `ssh-copy-id`, verificaste que quedó en
`authorized_keys`, y el servidor te sigue respondiendo
`Permission denied (publickey)`. ¿Qué revisás primero?

a) Que la clave privada tenga permisos `777` para que SSH pueda leerla
b) Los permisos: `~/.ssh` en `700` y `authorized_keys` en `600`, porque con `StrictModes` sshd ignora la clave en silencio
c) El `load average` del servidor
d) Borrás `~/.ssh/known_hosts` entero y reintentás

**8.** En `ps aux` ves decenas de procesos cuyo `STAT` empieza con `Z`.
¿Qué hacés?

a) `kill -9` a cada uno, de a uno
b) `renice -n -20` para que terminen antes
c) `kill -HUP 1` para que systemd los recoja
d) Nada con ellos: ya están muertos, hay que arreglar o reiniciar el proceso padre, que no leyó su código de salida

**9.** Editaste `/etc/systemd/system/tienda-api.service`, reiniciaste el servicio
y el cambio "no toma". ¿Qué te faltó?

a) `chmod 777 /etc/systemd/system/tienda-api.service`
b) `journalctl -f -u tienda-api`
c) `sudo systemctl daemon-reload`
d) `sudo systemctl mask tienda-api`

**10.** Matás el proceso padre de un servicio y, al mirar de nuevo con `ps -ef`,
el proceso hijo **sigue vivo** pero ahora su `PPID` es `1`. ¿Qué pasó?

a) El hijo quedó **huérfano** y `systemd` (PID 1) lo adoptó: sigue corriendo, ahora colgado del proceso de inicio
b) El hijo se transformó en zombie y por eso cambió de padre
c) El hijo se reinició solo y arrancó con un PID nuevo
d) `ps -ef` está mostrando datos viejos: hay que reiniciar la máquina para verlos bien

**11.** ¿Qué agenda la línea de crontab `0 9 * * 1-5`?

a) Todos los días a las 09:00
b) El día 9 de cada mes, a medianoche
c) Cada 9 minutos, todo el día
d) De lunes a viernes, a las 09:00

**12.** En el `PLAY RECAP` uno de los hosts aparece con `unreachable=1`.
¿Qué te está diciendo?

a) Que una tarea corrió y devolvió error
b) Que Ansible ni siquiera pudo conectarse a esa máquina: el problema es de red, SSH o inventario, no del playbook
c) Que un `when:` dio falso y la tarea se salteó
d) Que el handler no llegó a ejecutarse

**13.** ¿Cuál es la razón principal para dejar `PermitRootLogin no` en
`sshd_config`?

a) Porque así SSH negocia el cifrado más rápido
b) Porque el usuario `root` no puede tener clave pública
c) Porque cada persona entra con su usuario y escala con `sudo`: así queda registrado quién hizo cada cosa
d) Porque el puerto 22 no acepta conexiones de `root`

**14.** `uptime` muestra `load average: 18.40, 17.90, 16.20`, `nproc` devuelve 4,
y en `top` la CPU está casi toda en `id` pero `wa` marca 35. ¿Qué concluís?

a) Que la CPU es el cuello de botella y hay que agregar núcleos
b) Que el cuello de botella es el disco: el load average también cuenta los procesos en estado `D`
c) Que falta memoria RAM y el sistema está usando swap
d) Que el load average está mal calculado, porque nunca puede superar a `nproc`

**15.** Un servicio falla y en `systemctl status` aparece
`Process: ... status=203/EXEC`. ¿Qué mirás primero?

a) El `ExecStart=` de la unidad: la ruta tiene que ser absoluta y el archivo, ejecutable
b) El `WantedBy=` de la sección `[Install]`
c) La retención configurada del journal
d) El `load average` de la máquina

**16.** Tenés `a=9` y `b=10`. ¿Cuál de estas condiciones los compara como
números?

a) `[[ "$a" > "$b" ]]`
b) `[[ "$a" != "$b" ]]`
c) `[[ "$a" -gt "$b" ]]`
d) `[[ -n "$a" ]]`

**17.** Cambiaste un parámetro de configuración de un servicio web y **no querés
cortar** las conexiones que están en curso. ¿Qué hacés?

a) `sudo systemctl stop web` y después `sudo systemctl start web`: es lo mismo, pero más prolijo
b) `sudo systemctl mask web`, para que tome la configuración nueva
c) `sudo systemctl daemon-reload`, que recarga la configuración interna de todos los servicios
d) `sudo systemctl reload web`, si la unidad define `ExecReload=`; si no la define, no queda otra que `restart`

**18.** Un playbook usa `ansible.builtin.shell` sin `creates:` ni
`changed_when:`. ¿Qué consecuencia tiene?

a) Esa tarea reporta `changed` en todas las corridas: deja de ser idempotente
b) Ninguna: `shell` se comporta igual que cualquier otro módulo
c) El playbook no pasa el `--syntax-check`
d) Obliga a agregar `become: true` al play

**19.** Estás conectado por SSH a un servidor y querés terminar unos procesos
cuyo nombre contiene `ssh`. ¿Qué hacés **antes** de ejecutar `pkill -TERM ssh`?

a) Nada: `pkill` solo actúa sobre coincidencias exactas del nombre
b) Corrés `pgrep -a ssh` y leés la lista, porque `pkill` matchea por subcadena y podés matar tu propia sesión
c) Le das `chmod 777` al binario para asegurarte de tener permiso
d) Le subís el `nice` a 19 para que el sistema los termine solo

**20.** Dentro de un script querés obtener las últimas 50 líneas de error del
servicio `tienda-api`, sin que el script quede colgado esperando. ¿Qué comando
usás?

a) `journalctl -f -u tienda-api`
b) `journalctl -u tienda-api | less`
c) `journalctl -p debug`
d) `journalctl -u tienda-api -p err -n 50 --no-pager`

---

## Parte 2 — Verdadero o falso (21 a 30)

**21.** La clave que se copia al servidor con `ssh-copy-id` y termina en
`authorized_keys` es la pública (`.pub`); la privada nunca sale de tu máquina.

**22.** En la salida de `ps aux`, `VSZ` es la memoria realmente ocupada en RAM
por el proceso y `RSS` es apenas una reserva virtual.

**23.** `systemctl disable` alcanza para garantizar que un servicio no pueda
arrancar de ninguna manera.

**24.** Un script bien escrito usa dos canales de salida: los resultados van por
`stdout` y los errores y avisos por `stderr` (`>&2`), para que no se mezclen.

**25.** `for f in $(ls *.log)` es la forma recomendada de recorrer archivos en
Bash, porque `ls` los entrega ordenados.

**26.** Un handler de Ansible corre al final del play, una sola vez, y solo si
alguna tarea lo notificó con `notify:`.

**27.** Mover el servicio SSH del puerto 22 al 2222 es una medida de seguridad
sólida, porque un atacante ya no puede encontrar el servicio.

**28.** Terminar todos los scripts con un `exit 0` fijo es buena práctica, porque
así cron no molesta con avisos de error.

**29.** En Bash, `return` dentro de una función devuelve un estado (0 a 255), no
un dato: el dato se devuelve por `stdout` y se captura con `x=$(mi_funcion)`.

**30.** Si un playbook que venía dando `changed=0` empieza a reportar `changed` y
nadie tocó el repositorio, lo más probable es que alguien haya modificado el
servidor a mano.

---

## Terminaste

Guardá tus 30 marcas en `mi_solucion.md` (hay plantilla en la raíz del repo).
La corrección se hace **en vivo al final de la clase**: ahí anotás cuáles
erraste y a qué clase pertenecían.

Después, con esa lista en la mano, mirá
[`guia_de_estudio.md`](./guia_de_estudio.md): te dice qué releer según dónde
fallaste.
