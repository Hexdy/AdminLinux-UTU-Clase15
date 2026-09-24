<!-- Plantilla de Pull Request — completala antes de pedir la revisión. -->
<!-- 🏁 OJO: el reto de la bandera NO se entrega por PR: se la decís al profe.
     Esta plantilla es para cualquier OTRA entrega del repo (ejercicios, docs). -->
<!-- 💡 Y de paso: así es como se revisa un cambio de infraestructura en un trabajo
     real. El playbook vive en un repo y nadie toca producción sin que otro lo mire. -->

## Qué hice

<!-- Explicá en 1-2 frases qué resolviste y cómo. -->

## Playbook / comando(s) que usé

```yaml
# pegá acá tu solución
```

## Salida obtenida

<!-- Pegá el PLAY RECAP de las DOS corridas, o una captura de tu terminal. -->

```
PLAY RECAP *********************************************************
```

## Checklist

- [ ] Entiendo cada tarea que entrego (no la copié sin entender).
- [ ] Corrí el playbook **dos veces**: la segunda dio `changed=0` (**idempotente**).
- [ ] Probé con `--check --diff` antes de aplicar.
- [ ] Si usé `command`/`shell`, tiene `changed_when:` o `creates:` y explico por qué no
      había un módulo mejor.
- [ ] `become: true` está **solo** donde hace falta, no a nivel de play.
- [ ] Los permisos son concretos (`0640`/`0750`); **no hay ningún `0777`**.
- [ ] **No incluyo secretos**: ni contraseñas, ni tokens, ni claves privadas
      (`id_ed25519`, `*.pem`, `*.key`), ni archivos `vault_pass*` o `.env`.
- [ ] No incluyo IPs reales de producción ni datos sensibles.
- [ ] Trabajé en una rama, no en main.
