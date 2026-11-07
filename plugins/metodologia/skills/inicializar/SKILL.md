---
name: inicializar
description: Instala la metodología en el proyecto actual - detecta el stack, genera .claude/metodologia.json, permisos, CLAUDE.md, rules, OpenSpec y el runner de QA a partir de las plantillas del plugin. Usar cuando el usuario pida "inicializar la metodología", "instalar la metodología en este repo" o cuando el hook de inicio avise que falta .claude/metodologia.json. Es idempotente: en un proyecto ya configurado, solo completa lo que falta.
argument-hint: "[--solo <parte>]  partes: config | permisos | claude-md | rules | openspec | qa"
---

# inicializar — Instalar la metodología en este repo

Plantillas en `${CLAUDE_PLUGIN_ROOT}/templates/`. **Nunca pises un archivo existente sin mostrar el diff y preguntar.**

## 1. Detectar

Sin preguntar todavía:
- Apps: buscá `Gemfile`, `package.json` (¿vitest / jest / react?), `pyproject.toml`/`requirements.txt`, `go.mod` en la raíz y en subdirectorios de primer nivel.
- Stack de cada app → `rails` · `vitest` · `jest` · `pytest` · `custom` (ver `${CLAUDE_PLUGIN_ROOT}/hooks/adapters/README.md`).
- Reviewer: `rails-reviewer` para Rails, `react-reviewer` para React, `code-reviewer` para el resto.
- Ya existentes: `.claude/settings.json`, `CLAUDE.md`, `.claude/rules/`, `openspec/`, `tools/qa-runner/`, `.mcp.json`, `.github/workflows/` (¿deploy al pushear?).
- Herramientas: `jq` (obligatorio para los hooks), `openspec`, `codegraph`.

## 2. Preguntar (una sola ronda, `AskUserQuestion`)

Solo lo que no se deduce:
1. ¿Las apps detectadas son correctas? (mostralas con stack y reviewer)
2. Git: ¿directo a una rama (cuál) o ramas + PR? ¿El push dispara deploy?
3. Producción: ¿dónde se ven logs/deploys? (Railway MCP, Datadog, `kubectl`, ninguno…)
4. ¿Tiene UI con QA visual? → URL base, comando para levantar, ¿login? ¿tema claro/oscuro?

## 3. Generar (en este orden, mostrando un resumen de cada paso)

1. **`.claude/metodologia.json`** desde `templates/metodologia.json` con las respuestas. Borrá las apps y campos que no apliquen.
2. **`.claude/settings.json`**: mergeá con `jq` los permisos de `templates/settings.json` (allow/ask/deny) **sin borrar** lo existente. Adaptá los comandos de test/lint al stack. Agregá `enabledPlugins` y `extraKnownMarketplaces` para que el plugin se active solo en el equipo.
3. **`CLAUDE.md`**: si no existe, desde `templates/CLAUDE.md`. Si existe, proponé solo las secciones faltantes (Flujo de trabajo, Git y deploy, Producción, Guardrails).
4. **`.claude/rules/`**: copiá las de `templates/rules/` que correspondan al stack, **ajustando los `paths:`** a los directorios reales. Las `review-*.md` son ejemplos: dejalas como esqueleto para que el usuario complete sus convenciones.
5. **OpenSpec**: si está el CLI y no hay `openspec/`, pedile al usuario que corra `! openspec init` (es interactivo: elegir Claude Code). Después escribí `openspec/config.yaml` desde `templates/openspec-config.yaml` con el contexto del proyecto.
6. **QA** (si tiene UI): copiá `templates/qa-runner/` a `tools/qa-runner/`, `npm install` adentro, y agregá a `.gitignore`: `tmp/qa/`, `tools/qa-runner/node_modules/`. Pedile al usuario que cree un usuario de QA y lo ponga en `CLAUDE.local.md` (`QA_EMAIL`, `QA_PASSWORD`).
7. **`.gitignore`**: asegurá `CLAUDE.local.md` y `.claude/settings.local.json`.
8. **codegraph** (opcional): si está instalado, `.mcp.json` con el server `codegraph` (`codegraph serve --mcp`) y `enabledMcpjsonServers` en settings.

## 4. Verificar

- `jq . .claude/metodologia.json` y `jq . .claude/settings.json` válidos.
- Simulá el hook de lint sobre un archivo real de cada app:
  `echo '{"tool_input":{"file_path":"<abs>"}}' | CLAUDE_PROJECT_DIR=$PWD bash "${CLAUDE_PLUGIN_ROOT}/hooks/lint-on-edit.sh"; echo $?`
- Listá qué quedó y qué tiene que hacer el usuario (credenciales QA, `openspec init`, completar `review-*.md`, reiniciar la sesión para que tomen los hooks).

## Nunca

- Commitear: lo decide el usuario.
- Copiar credenciales o contenido de otro proyecto.
- Pisar `CLAUDE.md`, settings o rules existentes sin preguntar.
