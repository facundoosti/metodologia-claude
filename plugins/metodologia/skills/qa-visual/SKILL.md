---
name: qa-visual
description: QA visual en el navegador para cambios de UI. Clasifica el riesgo, arma casos TC-XX, automatiza lo posible (tests de componentes o Playwright con scripts) y usa Chrome DevTools MCP solo para lo exploratorio. Revisa cada caso y audita/corrige los errores. Usar al terminar cualquier cambio con impacto visual (pantallas, componentes, estilos, temas, layout), o cuando el usuario pida "QA", "probar en el navegador" o "revisión visual".
---

# QA visual

La feature no termina hasta que todos los casos **must** pasen o el usuario acepte explícitamente un fallo.

**Principio:** el navegador es la herramienta más cara. Primero se decide **cuánto** probar (riesgo), después **dónde** (test de componentes > script Playwright > DevTools MCP) y recién al final se abre el navegador.

Config: `.claude/metodologia.json` → `qa` (`base_url`, `health`, `start_cmd`, `viewport`, `themes`, `login`, `theme_storage_key`).

## ¿Cuándo aplica?

Si el diff toca componentes/páginas, estilos, layout, temas, formularios, modales, tablas o flujos de usuario.
No aplica a cambios sin efecto en UI (decilo y saltealo).

## Requisitos previos

1. App corriendo: `curl -sf` a cada URL de `qa.health`. Si no está, pedile al usuario que la levante (`qa.start_cmd`); no la levantes en background.
2. Runner: `tools/qa-runner/node_modules` existe (si no: `cd tools/qa-runner && npm install`). Si falta `tools/qa-runner`, copialo de `${CLAUDE_PLUGIN_ROOT}/templates/qa-runner/`.
3. Credenciales de QA en `CLAUDE.local.md` (`QA_EMAIL` / `QA_PASSWORD`, git-ignored). Se pasan **solo como variables de entorno** en el comando; **nunca** en archivos versionados ni en el reporte.
4. DevTools MCP (`mcp__chrome-devtools__*`) solo si hay casos exploratorios. Si no aparecen, avisá que corra `/mcp`.

## Paso 0 — Riesgo

Por **impacto**, no por tamaño del diff. Ante la duda, el nivel más alto.

| Riesgo | Cuándo | Alcance |
|---|---|---|
| **Bajo** | Ajuste visual de 1 componente, sin lógica | 1–3 casos · un tema · sin regresión salvo vecino directo |
| **Medio** | Cambia comportamiento o una pantalla; componente compartido | Casos de la spec + 1 regresión por consumidor (`codegraph impact`) · todos los temas **solo si tocó colores/tokens** |
| **Alto** | Layout global, tema/tokens globales, flujos de datos, auth | Todos los temas en los must + regresión de pantallas vecinas |

Escribí el nivel y una frase de justificación al principio del plan.

## Paso 1 — Casos `TC-XX`

Plan:
- Change de OpenSpec activo → `openspec/changes/<change>/qa.md` (+ `qa.mjs`)
- Sin OpenSpec → `docs/qa/<AAAA-MM-DD>-<slug>.md` (+ `.qa.mjs`)

Reglas:
- **No transcribas la spec.** Cada `#### Scenario:` es un caso: citá su origen y resumí el `THEN`. Sin spec → `origen: diff`.
- QA aporta lo que la spec no cubre: **regresión** (consumidores) y **bordes** (vacío, uno, muchos, error de API, permisos).
- Prioridad: **must** / **should**. Los must primero.

Ejecutor por caso — el más barato que observe la regla:

| Ejecutor | Para qué |
|---|---|
| `unit` | Estados (cargando, vacío, error), validaciones, lógica de render — test de componentes del proyecto; queda como regresión |
| `script` | Layout, tema, persistencia, flujos repetibles — `.qa.mjs` corrido por `tools/qa-runner/run.mjs` |
| `mcp` | Exploratorio (hover fino, drag, mirar un layout nuevo) — caro, con moderación |
| `manual` | Lo que requiere al usuario |

Formato:

```markdown
## Riesgo: medio — cambia el sidebar compartido

- [ ] **TC-01** · must · script · desktop-dark,desktop-light · Colapsar/expandir cambia el ancho — *spec: layout › Sidebar › Colapsar*
- [ ] **TC-02** · must · unit · Lista vacía muestra el estado vacío — *borde*
- [ ] **TC-03** · should · mcp · desktop-dark · Hover del rail se ve como overlay — *origen: diff*
```

Mostrale al usuario la lista antes de ejecutar.

## Paso 2 — Ejecución (de lo barato a lo caro)

1. **`unit`**: escribí/ajustá el test y corrélo.
2. **`script`**: escribí el `.qa.mjs` (ver `tools/qa-runner/example.qa.mjs`) y corré:
   ```bash
   QA_EMAIL=… QA_PASSWORD=… node tools/qa-runner/run.mjs <archivo.qa.mjs> [--only TC-01,TC-04]
   ```
   - `check` devuelve `{ pass, reason, facts }`; `facts` (JSON chico medido) es la evidencia.
   - El runner ya revisa errores de consola y requests ≥ 400 (`allowStatus` para esperados) y guarda capturas en `tmp/qa/<slug>/`.
3. **`mcp`**: delegá en `metodologia:qa-visual-runner` (ruta del plan, IDs, carpeta de evidencia, credenciales en el prompt).

**Reuso:** un ✅ no se re-corre si no cambiaron sus archivos desde ese resultado. Tras un fix, solo los afectados (`--only`).

Resultados: ✅ pass · ❌ fail · 🚧 blocked · ⏭️ not-run (con motivo). **Nunca** ✅ sin ejecutar.

## Paso 3 — Revisión

Abrí solo las capturas de los ❌ y de los `mcp` visuales. Actualizá cada caso: `[x]` + resultado + SHA corto + evidencia en una línea.

## Paso 4 — Auditoría y corrección

Por cada ❌: causa raíz con evidencia → fix respetando `.claude/rules/` de UI → tests + lint → re-correr el caso + regresiones → registrar en `## Hallazgos`.
Máximo 3 ciclos por caso; después escalá. Los ⚠️ se reportan, no se corrigen sin preguntar.
Un comportamiento que **debería estar en la spec y no está** → **gap de spec**.

## Cierre

Riesgo, ✅/❌/🚧/⏭️ por ejecutor, hallazgos corregidos, gaps de spec, pendientes y ruta al plan.
En un change de OpenSpec, QA visual va **después** de los reviewers y **antes** de spec-verifier.
