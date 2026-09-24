# El estado deseado del reto (la letra chica de la Parte A)

Tu playbook `mi_provisionar.yml` tiene que **garantizar** este estado dentro de
`datos/reto/servidor/`. No importa cuántas veces lo corras: la **segunda** corrida
tiene que dar `changed=0`.

| # | Ruta | Cómo tiene que quedar |
|---|---|---|
| 1 | `servidor/etc/` | Existe, es **directorio**, modo `0755` |
| 2 | `servidor/var/log/` | Existe, es **directorio**, modo `0755` |
| 3 | `servidor/etc/app.conf` | Copia de `../plantillas/app.conf.base` (o sea: contiene `modo=produccion`), modo **`0640`** |
| 4 | `servidor/etc/hosts_extra` | Contiene **exactamente UNA** línea útil: `10.0.10.20 appsrv` |

> "Línea útil" = ni vacía, ni comentario (`#`).

## Lo que el playbook heredado hace mal

| Tarea heredada | El problema | Por dónde va la solución |
|---|---|---|
| Crea el directorio de logs con `command: mkdir -p` | `mkdir -p` no falla si ya existe, pero Ansible **no lo sabe**: reporta `changed` siempre. | Hay un módulo que se ocupa de directorios. Ver la chuleta. |
| Copia la config con `shell: cp ...` | Siempre `changed`, y encima **no fija permisos**: queda con los que herede. | Hay un módulo que copia **y** pone `mode:`. |
| Agrega el host con `shell: echo ... >> hosts_extra` | `>>` **agrega siempre**. Corré 5 veces y tenés 5 líneas iguales. | Hay un módulo cuyo trabajo es "que esta línea esté, una sola vez". |

Las otras tres tareas con `command` **sí** están bien marcadas (tienen
`changed_when:` o `creates:`). Fijate cuáles antes de tocar nada: eso te ayuda con
la pregunta **R2**.

## Cómo comprobás que te quedó bien

```bash
# desde playbooks/
ansible-playbook auditar_idempotencia.yml -l local

# la prueba de fuego, desde datos/reto/
ansible-playbook mi_provisionar.yml -l local    # <- mirá el PLAY RECAP
```

Buscás esto:

```
PLAY RECAP ****************************************
localhost : ok=5  changed=0  unreachable=0  failed=0
                     ^^^^^^^^^
                     esto es lo que tiene que dar 0
```

## Lo que NO tenés que hacer

- ❌ Borrar `servidor/` y crearlo de cero a mano. El playbook tiene que poder
  arreglarlo solo, desde cualquier estado.
- ❌ Usar `shell: sed -i ...` para limpiar el `hosts_extra`. Anda, pero seguís
  con el mismo problema: `changed` siempre. Buscá el módulo.
- ❌ Tocar `../evidencia/`. Está en **solo lectura** (`0444`) a propósito: es la
  prueba del delito y de ahí salen R1 y R3.
- ❌ Poner `become: true` a nivel del play "por las dudas". Menor privilegio:
  acá no hace falta `sudo` para nada.

## El detalle que separa un playbook bueno de uno que miente

Mirá `armar_reto.yml`: la plantilla `mision.txt.j2` **no tiene la fecha**. Si la
tuviera, cada corrida generaría un archivo distinto y el `template` diría
`changed` para siempre. Una línea de más y perdés la idempotencia.

Pequeño, pero es exactamente la diferencia entre automatizar y hacer ruido.
