# Glosario — IaC y Ansible en criollo

> Orden: primero la idea en una frase, después el tecnicismo. Si un término te
> suena a chino, leelo igual: el 80% de las entrevistas técnicas de sistemas
> empieza preguntando estas palabras.

## Los conceptos grandes

| Término | En criollo |
|---|---|
| **Infraestructura como Código (IaC)** | La configuración del servidor **escrita en un archivo** que vive en Git, se revisa y se vuelve a aplicar. La receta, no la memoria del cocinero. |
| **Estado deseado** | Vos describís **cómo tiene que quedar**, no los pasos para llegar. "Quiero el paquete instalado", no "corré `apt install`". |
| **Idempotencia** | Aplicarlo 1 vez o 5 veces da **el mismo resultado**. El botón del ascensor. La 2ª corrida en verde es la prueba de que tu playbook está bien escrito. |
| **Desvío de configuración** (*drift*) | El servidor se fue de lo que dice el código, casi siempre porque **alguien lo tocó a mano**. Se detecta justamente con una corrida idempotente que reporta `changed` donde no debería. |
| **Servidor mascota** | El servidor único, configurado a mano, que nadie se anima a tocar ni a reiniciar. Lo contrario: **ganado** (se reemplaza sin drama porque está descrito en código). |
| **Aprovisionar** (*provisioning*) | Dejar una máquina lista para trabajar: paquetes, usuarios, configuración, servicios. |
| **Sin agente** (*agentless*) | No instalás **nada** en el servidor destino. Ansible entra por SSH y usa el Python que ya está ahí. |
| **Menor privilegio** | `sudo` **solo** donde hace falta, no en todo el playbook. |
| **Revisión por pares** | Como el playbook está en Git, el cambio riesgoso se ve en un Pull Request **antes** de tocar producción. El verdadero superpoder de IaC. |

## Las piezas de Ansible

| Pieza | Qué es | Archivo típico |
|---|---|---|
| **Nodo de control** | La máquina desde la que corrés Ansible. Ahí vive el código. | tu VM |
| **Nodo administrado** | El servidor al que le hablás. No tiene Ansible instalado. | `web01`... |
| **Inventario** | La lista de **a quién le hablo**, organizada en grupos. | `inventory.ini` |
| **Módulo** | La unidad de trabajo. Sabe hacer **una** cosa de forma idempotente. | `package`, `copy` |
| **Tarea** (*task*) | Un módulo + sus parámetros + un **nombre** en castellano. | `- name: ...` |
| **Play** | Un conjunto de tareas apuntado a un grupo de hosts. | `hosts: web` |
| **Playbook** | El archivo YAML con uno o más plays. La receta completa. | `sitio.yml` |
| **Handler** | Tarea que corre **al final** y **solo si** algo la notificó. "Si cambió la config, **entonces** reiniciá." | `handlers:` |
| **Variable** | Un valor con nombre que usás en tareas y plantillas. | `vars:` |
| **Fact** | Variable que Ansible **descubre** del host (`ansible_os_family`). | *Gathering Facts* |
| **Plantilla Jinja2** | Un archivo con agujeros `{{ }}` que se rellenan con variables. | `mision.txt.j2` |
| **Rol** | Un playbook ordenado en carpetas, reutilizable y compartible. | `roles/sitio_web/` |
| **Colección** | Un paquete de módulos y roles. `ansible.builtin` es la que viene de fábrica. | — |
| **Bóveda** (*Vault*) | El mecanismo de Ansible para guardar un archivo **cifrado** dentro del repo. | `vault_pass` (nunca se commitea) |

## Los estados que te reporta cada tarea

| Estado | Qué significa | Cómo leerlo |
|---|---|---|
| `ok` | Ya estaba como pediste. **No hizo nada.** | 💚 En una 2ª corrida, esto es el éxito. |
| `changed` | Faltaba, y lo puso. | 🟠 En la 1ª corrida es normal. En la 2ª es sospechoso. |
| `failed` | No pudo. Cortó el play para ese host. | 🔴 Leé el mensaje: casi siempre es permisos o una ruta. |
| `skipped` | La saltó porque un `when:` dio falso. | ⚪ No es error. |
| `unreachable` | Ni siquiera pudo **conectarse** (SSH, DNS, host apagado). | 🔴 No es culpa del playbook. |
| `rescued` | Falló dentro de un `block:` y el `rescue:` la levantó. | 🟡 Degradación controlada. |
| `ignored` | Falló pero tenía `ignore_errors: true`. | ⚪ Usalo poco. |

## El vocabulario del rubro (lo vas a escuchar, no hace falta que lo sepas hoy)

| Término | Una frase |
|---|---|
| **Gestión de configuración** | La familia de herramientas a la que pertenece Ansible: dejar servidores existentes en el estado deseado. Hay **varias** en el mercado. |
| **Aprovisionamiento de infraestructura** | Otra familia: **crear** la infraestructura (máquinas, redes) en la nube, también desde archivos. |
| **Contenedores** | Empaquetar la app con todo lo que necesita para correr igual en todos lados. |
| **CI/CD** | Canalizaciones que prueban y despliegan tu código (y tus playbooks) automáticamente en cada cambio. |
| **GitOps** | El repositorio Git es la única fuente de verdad: si no está en el repo, no existe. |
| **SRE** | El perfil que se ocupa de que el servicio sea confiable, con fuerte apoyo en automatización. |

## Comandos que vas a tipear

| Comando | Qué hace |
|---|---|
| `ansible --version` | Qué versión tenés y dónde busca la config. |
| `ansible-playbook sitio.yml --check --diff` | Simulacro con antes/después. |
| `ansible-playbook sitio.yml -l web` | Aplica solo al grupo `web`. |
| `ansible-playbook sitio.yml --syntax-check` | Revisa el YAML sin conectarse a nada. |
| `ansible-inventory --list` | Te muestra cómo Ansible entendió tu inventario. |
| `ansible-doc ansible.builtin.copy` | La documentación del módulo, **offline**, en tu terminal. |
| `ansible localhost -m ansible.builtin.ping` | Un comando suelto (*ad-hoc*), sin playbook. |

> `ansible-doc` es tu mejor amigo contra las alucinaciones de la IA: si un
> asistente te inventa un parámetro, `ansible-doc` te dice en 3 segundos que no existe.
