# Chuleta del Bloque B (Clases 9 a 13)

Una hoja. Lo que más cae, ordenado por clase. Si algo de acá no te suena, ese es
el apunte que tenés que releer.

## C9 — Procesos y señales

```bash
ps aux                       # BSD: USER PID %CPU %MEM VSZ RSS STAT
ps -ef                       # UNIX: UID PID PPID
ps aux --sort=-%mem | head   # los mas pesados primero
pgrep -a nginx               # MIRAR antes de matar (matchea subcadena)
kill -TERM <pid>             # 15, el default: pedido ordenado
kill -9 <pid>                # KILL: ultimo recurso, no se puede atrapar
kill -HUP <pid>              # 1: relee configuracion
uptime ; nproc               # load average / nucleos: dividir uno por el otro
free -h                      # mirar available, NO free
jobs ; bg %1 ; fg %1         # Ctrl+Z deja el proceso en estado T
nice -n 10 comando           # 0 default, -20..19, negativo solo root
```

| Estado `STAT` | Qué es |
|---------------|--------|
| `R` | Corriendo o listo para correr |
| `S` | Durmiendo, interrumpible (lo normal) |
| `D` | Espera ininterrumpible de disco o red. **Suma al load** |
| `Z` | Zombie: ya terminó. No se mata; se arregla el **padre** |
| `T` | Detenido (`Ctrl+Z` o `SIGSTOP`) |

`RSS` = memoria real en RAM · `VSZ` = virtual reservada · `%CPU` > 100 = varios
núcleos.

## C10 — systemd y journalctl

```bash
systemctl status <unidad>           # Loaded / Active / Main PID / CGroup / log
sudo systemctl start|stop|restart <unidad>
sudo systemctl reload <unidad>      # sin cortar el servicio (necesita ExecReload=)
sudo systemctl enable --now <unidad>
sudo systemctl disable <unidad>     # saca el arranque automatico
sudo systemctl mask <unidad>        # lo bloquea (enlace a /dev/null)
sudo systemctl daemon-reload        # SIEMPRE tras editar una unidad
systemctl is-active <unidad> ; systemctl is-enabled <unidad>
journalctl -u <unidad> -n 50 --no-pager
journalctl -u <unidad> -p err       # err y peores
journalctl -b ; journalctl -b -1    # este arranque / el anterior
journalctl -f -u <unidad>           # en vivo
journalctl -t <tag> --no-pager      # lo que mando tu script con logger
```

* `/usr/lib/systemd/system/` = del paquete (no tocar) ·
  `/etc/systemd/system/` = tuyo (gana).
* `start` = ahora · `enable` = próximo boot.
* `203/EXEC` = ruta de `ExecStart=` mala · `200/CHDIR` = `WorkingDirectory=`
  inexistente · `217/USER` = `User=` inexistente. En los tres el programa **ni
  arrancó**.
* Nombre del servicio SSH: `ssh` (Debian/Ubuntu) · `sshd` (Arch/Fedora).
  Cron: `cron` · `cronie`/`crond`.

## C11 — SSH

```bash
ssh-keygen -t ed25519 -C "ulyses@laptop"    # con passphrase
ssh-copy-id -i ~/.ssh/id_ed25519.pub <usuario>@<servidor>
ssh -p 2222 <usuario>@<servidor>            # ssh usa -p
scp -P 2222 archivo <usuario>@<servidor>:   # scp usa -P
rsync -avz --dry-run origen/ destino/       # la barra final importa
ssh-keygen -R <servidor>                    # host key cambiada (si sabés por qué)
sudo sshd -t                                # validar sintaxis ANTES de reload
sudo sshd -T                                # ver la configuración efectiva
```

| Archivo | Permiso |
|---------|---------|
| `~/.ssh` | `700` |
| `~/.ssh/id_ed25519` (privada) | `600` — **nunca sale de tu máquina** |
| `~/.ssh/id_ed25519.pub` | `644` — esta sí se reparte |
| `~/.ssh/authorized_keys` | `600` |

Endurecer `sshd_config`: `PermitRootLogin no`, `PasswordAuthentication no` (solo
después de probar la clave), `AllowUsers`, `MaxAuthTries 3`, `X11Forwarding no`.
**Gana la primera aparición** de cada directiva; validá con `sshd -t`, aplicá con
`reload` y probá desde **otra** terminal.

Diagnóstico: `Connection refused` = nadie escucha · `Connection timed out` =
red o firewall · `Permission denied (publickey)` = clave, permisos o config.

## C12 — Shell scripting

**Los cinco escalones:** guardar · decidir · repetir · ordenar · correr solo.

### 1 y 2 — Guardar y decidir

```bash
#!/usr/bin/env bash
set -euo pipefail                   # -e corta, -u variable indefinida, pipefail
NOMBRE="${1:?falta el nombre}"      # obligatorio
PUERTO="${2:-22}"                   # con default
readonly LOG="/var/log/chequeo.log"
[[ -f "$ARCHIVO" ]] || { echo "no existe: $ARCHIVO" >&2 ; exit 2 ; }
if systemctl is-active --quiet ssh ; then printf 'ok\n' ; fi
case "${1:-}" in start) ... ;; stop) ... ;; *) echo "uso: $0 start|stop" >&2 ;; esac
```

| Números | Texto |
|---------|-------|
| `-eq -ne -gt -ge -lt -le` | `== != < > -z -n` |

`[[ 9 > 10 ]]` es **verdadero** (compara texto). Pruebas de archivo: `-e -f -d
-r -w -x -s`. Códigos de salida: `0` éxito · `1` genérico · `2` mal uso ·
`126` no ejecutable · `127` no encontrado · `130` Ctrl+C.

Errores a `stderr` (`>&2`). Comillas siempre — y `"$@"`, nunca `$*`. `bash -x
script.sh` para depurar; `shellcheck` para revisar. Si aparece
`bash\r: command not found`, el archivo tiene CRLF: `sed -i 's/\r$//' script.sh`.

### 3 y 4 — Repetir y ordenar

```bash
for f in *.log ; do [[ -e "$f" ]] || continue ; echo "$f" ; done   # NO $(ls)
while IFS= read -r linea ; do echo "$linea" ; done < "$ARCHIVO"
while read -r n ; do total=$((total+n)) ; done < <(comando)  # evita el subshell
mi_funcion() { local x="$1" ; printf '%s\n' "$x" ; return 0 ; }
resultado="$(mi_funcion hola)"      # el dato sale por stdout, no por return
main() { validar "$@" ; recolectar ; informar ; } ; main "$@"
TMP="$(mktemp)" ; trap 'rm -f "$TMP"' EXIT INT TERM
```

`local` en toda variable de función (si no, pisa las de afuera). `return` es
**estado** (0–255); el **dato** sale por `echo`/`printf`.

### 5 — Correr solo: `logger`, cron y timers

```bash
logger -t chequeo -p user.info "todo ok"    # journalctl -t chequeo --no-pager
crontab -l > ~/cron.bak                     # respaldo de un segundo
systemctl list-timers                       # la alternativa moderna a cron
```

```
   min  hora  diaMes  mes  diaSemana     0 y 7 = domingo
    0    9      *      *      1-5        lunes a viernes 09:00
   */10  *      *      *       *         cada 10 minutos
    30   3      1      *       *         dia 1 de cada mes, 03:30
```

Si día-del-mes **y** día-de-semana son los dos distintos de `*`, cron hace **O**,
no **Y**: `0 3 1 * 1` corre el día 1 **o** todos los lunes.

**Las cuatro trampas de cron:** `PATH` mínimo (usar rutas absolutas) · no lee tu
`.bashrc` · `%` es especial (escapar `\%`) · la salida se pierde (redirigir o
`logger`). Depurar: `journalctl -u cron` y `env -i /bin/sh -c '/ruta/script.sh'`.

`crontab -e` edita · `crontab -l` lista · `crontab -r` **borra todo sin
preguntar**.

**Timer de systemd** = `respaldo.timer` (cuándo) + `respaldo.service` (qué).
Ventajas sobre cron: log en el journal, `Persistent=true` (recupera lo que se
perdió con la máquina apagada) y se depura con las herramientas de C10.

## C13 — Ansible e IaC

```bash
ansible -i inventario.ini todos -m ping
ansible-playbook -i inventario.ini sitio.yml --syntax-check
ansible-playbook -i inventario.ini sitio.yml --check --diff   # ensayo
ansible-playbook -i inventario.ini sitio.yml -l web -K        # -K pide sudo
```

```yaml
- name: Configurar servidores web
  hosts: web
  become: true
  tasks:
    - name: Instalar nginx
      ansible.builtin.package:
        name: nginx
        state: present
    - name: Copiar configuración
      ansible.builtin.template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
      notify: Reiniciar nginx
  handlers:
    - name: Reiniciar nginx
      ansible.builtin.service:
        name: nginx
        state: restarted
```

| `PLAY RECAP` | Significa |
|--------------|-----------|
| `ok` | Ya estaba como debía |
| `changed` | Ansible modificó algo |
| `failed` | La tarea corrió y falló |
| `unreachable` | Ni pudo conectarse: red/SSH/inventario |

**Idempotencia:** la 2.ª corrida sin cambios tiene que dar `changed=0`.
`command`/`shell` sin `creates:` ni `changed_when:` **rompen** la idempotencia.
Los handlers corren al final, una vez, solo si alguien los notificó, y el
`notify:` tiene que coincidir exacto con el `name:`.
