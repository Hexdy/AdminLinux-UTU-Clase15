# AdminLinux · Clase 15 — Repaso B: de un servidor a veinte

Repositorio de la **Clase 15** de Administración de Sistemas Linux (UTU).
Es el **repaso integrador del Bloque B** (Clases 9 a 13) y la última clase antes
del **Parcial 2** (Clase 16, 25 de noviembre).

> **Cinco clases, una sola historia.** Entra un servidor nuevo al equipo, es
> viernes a las 18:00 y vos lo tenés que dejar andando: entrás por SSH con clave
> (C11), mirás qué está corriendo (C9), descubrís que un servicio no arranca y
> leés el journal (C10), escribís un script que hace el diagnóstico solo y lo
> agendás con cron para que corra todas las noches (C12) y, en vez de repetir
> todo a mano en los otros 19 servidores, lo declarás una sola vez con Ansible
> (C13).

## El reto de hoy

**El reto es el simulacro del Parcial 2.** 30 preguntas (20 múltiple opción +
10 verdadero/falso), **solo, cronometrado en 25 minutos, sin apuntes y sin IA**.

No lleva nota. Lo que importa es que salgas de la clase sabiendo **exactamente**
qué tenés que estudiar para el 25 de noviembre.

1. Cloná este repositorio.
2. Abrí [`docs/simulacro_parcial.md`](./docs/simulacro_parcial.md) y poné el
   cronómetro.
3. Volcá tus respuestas en `mi_solucion.md` (hay plantilla acá mismo).
4. Corregimos en vivo al final de la clase.
5. Con tus errores en la mano, seguí
   [`docs/guia_de_estudio.md`](./docs/guia_de_estudio.md).

## Qué hay acá

| Archivo | Para qué sirve |
|---------|----------------|
| [`docs/mapa_del_bloque.md`](./docs/mapa_del_bloque.md) | El hilo narrativo de las cinco clases: concepto madre, error típico y pregunta que cae, clase por clase |
| [`docs/simulacro_parcial.md`](./docs/simulacro_parcial.md) | Las 30 preguntas del simulacro |
| [`docs/chuleta_bloque_b.md`](./docs/chuleta_bloque_b.md) | Una hoja con todo lo del Bloque B: comandos, tablas y trampas |
| [`docs/guia_de_estudio.md`](./docs/guia_de_estudio.md) | Qué releer según dónde fallaste + estrategia para el día del parcial |
| [`docs/reto_pull_request.md`](./docs/reto_pull_request.md) | Cómo entregás tu `mi_solucion.md` por Pull Request |
| `mi_solucion.md` | Plantilla para tus 30 respuestas |

## Preguntas frecuentes

<details>
<summary><b>¿Qué tengo que hacer hoy, exactamente?</b></summary>

Tres cosas, en este orden:

1. Durante la clase, seguir el mapa del bloque y las seis estaciones (cinco por
   clase + el taller de errores que las cruza). Si algo no te cierra,
   **preguntá ahí**: es la última clase antes del parcial.
2. Cuando el docente lo indique, hacer el simulacro **solo y cronometrado**.
3. Después de la corrección en vivo, anotar **qué clase** tenía cada error y
   armar tu plan de estudio con `docs/guia_de_estudio.md`.

El simulacro **no lleva nota**. Si lo hacés con ayuda, el resultado te miente y
vas a estudiar lo que no era.
</details>

<details>
<summary><b>No me acuerdo de nada de una de las clases. ¿Por dónde empiezo?</b></summary>

Por el mapa, no por el apunte. Abrí
[`docs/mapa_del_bloque.md`](./docs/mapa_del_bloque.md) y leé el **concepto
madre** de esa clase: es una sola idea. Si esa idea te vuelve, seguí con la
sección de la clase en [`docs/chuleta_bloque_b.md`](./docs/chuleta_bloque_b.md).

Recién si la chuleta tampoco te dice nada, volvé al apunte completo de esa clase
y rehacé su ejercicio. Leer el apunte de punta a punta sin haber entendido el
concepto madre es la forma más lenta de estudiar.
</details>

<details>
<summary><b>¿Puedo usar IA para el simulacro?</b></summary>

**Para el simulacro, no.** El simulacro es un termómetro: si lo respondés con
ayuda, te vas a llevar un diagnóstico falso y vas a estudiar lo que no hacía
falta. El parcial va a ser sin IA, así que el ensayo también.

**Después de corregir, sí.** Ahí la IA es excelente para lo que más cuesta
solo: pedirle que te **explique por qué** una opción era incorrecta, que te
invente variantes del mismo escenario con otros números, o que te tome preguntas
nuevas sobre el tema que fallaste.

Regla que ya conocés de todo el curso: nunca ejecutes un comando con `sudo`,
`rm` o redirecciones sin entender antes qué hace. La IA se equivoca con
confianza.
</details>

<details>
<summary><b>¿Cómo entrego?</b></summary>

Por Pull Request, igual que siempre — y por eso mismo no es solo un trámite:
es la última práctica del flujo Git antes del parcial.

Está todo paso a paso en
[`docs/reto_pull_request.md`](./docs/reto_pull_request.md): fork, rama con tu
nombre, `mi_solucion.md` completo, commit y PR contra este repositorio.

La entrega **no lleva nota**. Sirve para que el docente vea, sobre el grupo
entero, qué temas quedaron flojos y pueda reforzarlos antes del 25 de noviembre.
</details>

<details>
<summary><b>¿Qué entra en el Parcial 2?</b></summary>

Todo lo de las **Clases 9 a 13**: procesos y señales, systemd y journalctl, SSH,
shell scripting completo (con `cron` y los timers), Ansible e IaC.

**No entra** el Bloque A (Clases 1 a 7: eso ya se evaluó en el Parcial 1), ni
temas que no vimos (expresiones regulares complejas, Ansible Vault, roles de
Galaxy, contenedores), ni memorizar de taquito un `.service` completo o un
`ansible.cfg`. Sí entra **entender** qué hace cada directiva que sí vimos.

El formato es el mismo del simulacro: 20 múltiple opción + 10 verdadero/falso,
individual, sin apuntes y sin IA. Algunas preguntas del simulacro reaparecen tal
cual; la mayoría son nuevas sobre los mismos temas con otros escenarios, así que
memorizar las respuestas **no alcanza**.
</details>

## Licencia y uso

Material docente de UTU para uso educativo. Las IP que aparecen en los ejemplos
son de documentación (`192.0.2.0/24`, `203.0.113.0/24`) y no corresponden a
ningún sistema real. No subas credenciales, tokens ni claves privadas a este
repositorio.
