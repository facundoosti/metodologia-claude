---
name: handoff
description: Genera un bloque copiable para continuar el trabajo actual en una conversación nueva, con el comando que corresponda (orquestar, quick-fix, openspec-apply-change, qa-visual…). No ejecuta nada. Usar cuando el usuario pida "handoff", "pasame esto a otra conversación", "cómo sigo en otro chat" o cuando una sesión larga se corta a mitad.
argument-hint: "[destino: orquestar | apply | quick-fix | qa | archive | bug]"
---

# handoff — Traspaso a otra conversación

El entregable es **un bloque**; el texto alrededor es la excepción.

## Destino

- Con argumento: `orquestar` → `/metodologia:orquestar` · `apply` → `/openspec-apply-change` · `qa` → `/metodologia:qa-visual` · `archive` → `/openspec-archive-change` · `fix` → `/metodologia:quick-fix` · `bug` → `/metodologia:bugbuster`.
- Sin argumento: deducilo del trabajo hecho. Si hay **dos** igual de válidos, `AskUserQuestion`.

## Datos (verificados, no recordados)

- Rama: `git branch --show-current`
- Change activo: `openspec list` (y etapa según `tasks.md`)
- Sin commitear: `git status --short` (cantidad + si hay migraciones)
- Entrada: archivo que la conversación nueva debe leer (`openspec/changes/<change>/`, `docs/fixes/…`, `docs/qa/…`)

**Omití lo no confirmado.** Una línea de menos es correcta; una inventada rompe la conversación siguiente.

## Bloque

````
```
/<comando> <argumento>

Rama: <rama>
Change: <change o N/A>
Entrada: <ruta>
Estado: <etapa · lo último verificado>
Sin commitear: <n archivos · migraciones sí/no>
Decisiones ya tomadas: <1–3 bullets, solo lo que no se deduce del repo>
```
````

## Reglas

- No resumas la conversación: si no entra en "Decisiones ya tomadas", va a un archivo (`docs/fixes/`, `design.md`) primero.
- Máximo 2 líneas fuera del bloque.
