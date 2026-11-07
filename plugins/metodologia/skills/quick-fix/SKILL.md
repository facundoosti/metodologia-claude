---
name: quick-fix
description: Corrige un bug acotado sin pasar por OpenSpec - test que reproduce, fix mínimo, review por sub-agente y registro en docs/fixes/. Usar cuando el usuario pida "arreglá este bug", "quick fix", o venga de un diagnóstico de bugbuster. No usar si el cambio necesita migración, cambia un contrato de API o toca más de ~5 archivos de producción → openspec-propose (u orquestar).
argument-hint: "<descripción del bug> | docs/fixes/<archivo>-diagnostico.md"
---

# quick-fix — Arreglo acotado

Que el fix sea chico **no** lo exime de test ni de review: los cambios chicos en auth, permisos o queries son donde se cuela lo grave.

## 1. ¿Es acotado?

Todo se cumple:
- ≤ ~5 archivos de producción y ~100 líneas (sin contar tests).
- Sin migración, sin cambio de contrato de API, sin cambio de comportamiento acordado en `openspec/specs/`.
- La causa está clara (si viene de bugbuster, leé ese archivo y **no** rehagas el diagnóstico).

Si algo falla → sugerí `/openspec-propose` o `/metodologia:orquestar`. Si la causa no está clara → `/metodologia:bugbuster`.

## 2. Registro

`docs/fixes/YYYY-MM-DD-<slug>.md`:

```markdown
# Fix: <título>

## Lectura rápida
<qué fallaba y qué se cambió>

## Error
- Síntoma: …
- Causa: … (`archivo:línea`)
- Origen: <usuario | docs/fixes/…-diagnostico.md>

## Plan
- [ ] Test que reproduce
- [ ] Fix mínimo
- [ ] Tests + lint
- [ ] Review
- [ ] QA visual (o N/A: razón)

## Solución

## Verificación
```

Actualizá el checklist en cada hito.

## 3. Test primero

Test que reproduce el bug en la capa correcta, siguiendo `.claude/rules/` de esa app. **Corrélo y velo fallar.** Aserción observable, no de implementación. Si no se puede reproducir con un test, anotá por qué.

## 4. Fix mínimo

Solo lo necesario para que el test pase. Nada de refactors de paso (van a "Seguimiento"). Antes de tocar un símbolo compartido: `codegraph impact <símbolo>`.

## 5. Tests + lint

Tests del archivo tocado y vecinos + lint de los archivos tocados. Todo verde antes de seguir.

## 6. Review (sub-agente)

El `reviewer` de cada app tocada (`apps[].reviewer` en `.claude/metodologia.json`). Corregí bloqueantes; sugerencias → "Seguimiento" salvo triviales.
Si el fix toca **auth, permisos, queries con input del usuario o integraciones externas**, pedile foco explícito en seguridad.

## 7. QA visual

Si cambió algo visible → `/metodologia:qa-visual` (riesgo bajo, plan en `docs/qa/`). Si no → `N/A` con razón.

## 8. Cierre

Completá Solución y Verificación. `AskUserQuestion`: **Commit + push (deploy)** · **Solo commit** · **No commitear**, listando los archivos y qué dispara el push.

Commit `fix: <qué>`, solo con los archivos del fix + el registro.

## Nunca

- Arreglar sin test (salvo imposibilidad anotada).
- Ampliar el alcance "ya que estoy".
- Pushear sin la pregunta del paso 8.
