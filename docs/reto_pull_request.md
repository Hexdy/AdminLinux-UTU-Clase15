# Entrega por Pull Request

El simulacro se entrega igual que los retos anteriores: **fork, rama, commit y
Pull Request**. No lleva nota — sirve para que el docente vea, sobre el grupo
entero, qué temas quedaron flojos y los refuerce antes del parcial.

> Esta es la última vez que practicás el flujo Git antes del Parcial 2.
> Aprovechala: hacelo sin mirar los pasos, y si te trabás, volvé acá.

## Antes de empezar

* Ya hiciste el simulacro **solo y cronometrado**.
* Ya lo corregimos en vivo y anotaste cuáles erraste.
* Tenés `mi_solucion.md` completo, con tus 30 respuestas **tal como las
  respondiste** (no las corregidas) y la reflexión del final.

## Paso a paso

```bash
# 1. Fork desde la web de GitHub (boton "Fork"), y despues:
git clone https://github.com/<tu-usuario>/AdminLinux-UTU-Clase15.git
cd AdminLinux-UTU-Clase15

# 2. Rama propia
git checkout -b entrega/<tu-apellido>

# 3. Completa mi_solucion.md con tu editor

# 4. Commit
git add mi_solucion.md
git commit -m "Entrega simulacro Parcial 2 - <Apellido> <Nombre>"

# 5. Subir tu rama
git push -u origin entrega/<tu-apellido>

# 6. Pull Request desde la web, contra la rama main del repo del curso
```

## Qué tiene que tener tu `mi_solucion.md`

1. Tu nombre y apellido.
2. Las **30 respuestas** como las respondiste durante el simulacro.
3. Cuántas acertaste (opcional, es para vos).
4. La tabla de errores por clase, completa.
5. Dos o tres líneas honestas sobre **qué vas a estudiar** y por qué.

El punto 5 es el que más sirve. "Me fue mal en cron" no dice nada; "erré 11, 17
y 25: me confundo el orden de los campos y no tengo claro el subshell del pipe"
es un plan de estudio.

## Reglas

* **Un PR por persona.** El título tiene que decir tu apellido.
* **No toques** `docs/` ni el `README.md`. Solo tu `mi_solucion.md`.
* **No subas** credenciales, claves privadas, `.env` ni capturas con datos
  reales.
* Si el PR tiene conflictos, actualizá tu rama desde `main` y resolvelos antes
  de avisar.

## Si algo sale mal

| Síntoma | Qué mirar |
|---------|-----------|
| `fatal: not a git repository` | No estás dentro de la carpeta clonada (`cd`) |
| `Permission denied (publickey)` | Estás clonando por SSH sin clave configurada: usá HTTPS o repasá la Clase 11 |
| `rejected ... non-fast-forward` | Tu rama quedó atrás: `git pull --rebase origin main` |
| El PR aparece vacío | Te olvidaste de `git push` o estás comparando la rama equivocada |
