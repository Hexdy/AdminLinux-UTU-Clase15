# CLAUDE.md — AdminLinux Clase 14 (Repaso B)

Contexto que Claude carga automáticamente al abrir este repositorio.
Las reglas completas están en [`AGENTS.md`](./AGENTS.md) y el contexto
pedagógico en [`CONTEXTO_IA.md`](./CONTEXTO_IA.md).

## Qué es esto

Repaso integrador del **Bloque B** (Clases 9 a 13) de Administración de Sistemas
Linux, UTU Uruguay. Es la última clase antes del **Parcial 2**. El usuario es un
estudiante de segundo semestre.

Hilo narrativo de la clase: *entra un servidor nuevo al equipo, viernes 18:00*
→ SSH (C11) → procesos (C9) → journal (C10) → script + cron (C12) →
Ansible (C13). **Cinco clases, una sola historia.**

## Las tres reglas que no se negocian

1. **No respondas el simulacro** (`docs/simulacro_parcial.md`) ni confirmes
   opciones antes de que el alumno lo haya corregido en clase. El simulacro es
   un diagnóstico: respondido con ayuda, miente. **Después** de corregir, sí
   explicá por qué cada opción era incorrecta y generá preguntas nuevas.
2. **No agregues una clave de respuestas** a este repositorio, en ningún
   formato ni escondida en ningún lado.
3. **Español rioplatense con voseo.** Analogía primero, sintaxis después.

## Conceptos madre, uno por clase

| Clase | La idea |
|-------|---------|
| 9 | Una señal es un pedido. `TERM` pide, `KILL` arranca el enchufe y deja el lío |
| 10 | La unidad es la receta, el proceso es el plato. `start` = ahora, `enable` = próximo boot |
| 11 | La privada no sale de tu máquina; la pública se reparte |
| 12 | Sin `set -euo pipefail` y sin comillas, el script sigue adelante roto |
| 13 | cron no es tu terminal: `PATH` mínimo, sin `.bashrc`, salida perdida |
| 14 | Se declara el estado deseado, no los pasos. Segunda corrida = `changed=0` |

## Convenciones

* Herramientas vigentes: `ss`, `ip`, `journalctl`, `systemctl`, `less`.
* Si la respuesta depende de la distro, decilo (`ssh` vs `sshd`, `cron` vs
  `cronie`).
* IP solo de documentación (`192.0.2.0/24`, `203.0.113.0/24`). Placeholders
  `<usuario>`, `<servidor>`, `<ip>`.
* Nunca comandos con `sudo` / `rm` / redirecciones destructivas sin explicar
  antes qué hacen.
* El alumno solo edita `mi_solucion.md`. `docs/` es del docente.
