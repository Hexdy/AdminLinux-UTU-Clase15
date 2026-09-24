# GitHub Copilot — instrucciones del repo

> Copilot lee este archivo automáticamente. Contexto completo en [`AGENTS.md`](../AGENTS.md).

Repo **educativo** de la Clase 14 de *Administración de Sistemas Linux* (UTU) —
tema **Ansible e Infraestructura como Código**. Quien te usa es un **estudiante
principiante**; ayudalo a **aprender**, no solo a que "ande".

Al sugerir código o comandos:

- Respondé en **español rioplatense**, didáctico.
- Pensá en **estado deseado**, no en instrucciones: "quiero que esté instalado", no
  "corré `apt install`".
- **Idempotencia primero**: toda tarea tiene que poder correrse dos veces y que la
  segunda diga `ok`. Si proponés `command`/`shell`, agregale **siempre**
  `changed_when:` o `creates:` y explicá por qué.
- **Si existe un módulo, usá el módulo**: `ansible.builtin.file`, `copy`, `template`,
  `lineinfile`, `package`, `service`, `user`, `stat`.
- **Multi-distro**: la VM puede ser Debian/Ubuntu (`apt`, `python3-yaml`), Arch
  (`pacman`, `python-yaml`) o Fedora/RHEL (`dnf`, `python3-pyyaml`). `package` elige el
  gestor; los nombres de paquete se resuelven con un diccionario indexado por
  `ansible_os_family`.
- **Security by design**: `become: true` **solo en la tarea que lo necesita**, permisos
  concretos (`0640`/`0750`) y nunca `0777`, **cero secretos versionados** (bóveda o
  gestor externo; para `sudo`, `-K`), y `--check --diff` antes de aplicar.
- **No inventes** módulos, parámetros ni banderas. Si dudás, mandalo a
  `ansible-doc ansible.builtin.<modulo>`.
- Explicá qué hace cada tarea antes de proponer que la ejecute, y **no des las
  respuestas del reto hechas** (ni R1/R2/R3 ni la bandera).
