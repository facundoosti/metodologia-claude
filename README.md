# metodologia-claude

Metodología de trabajo con Claude Code, empaquetada como plugin. Nació en el proyecto Lubricentro.

## Qué trae

| Capa | Qué | Dónde |
|---|---|---|
| 🛠️ Skills | `orquestar` · `bugbuster` · `quick-fix` · `qa-visual` · `handoff` · `inicializar` | `plugins/metodologia/skills/` |
| 🤖 Agentes | `rails-reviewer` · `react-reviewer` · `code-reviewer` · `spec-verifier` · `qa-visual-runner` | `plugins/metodologia/agents/` |
| ⚙️ Hooks | contexto al iniciar · protección de secretos/lockfiles/generados · lint al editar · tests afectados al terminar | `plugins/metodologia/hooks/` |
| 📄 Plantillas | `metodologia.json` · `settings.json` (permisos) · `CLAUDE.md` · `openspec/config.yaml` · rules · runner de QA (Playwright) | `plugins/metodologia/templates/` |

**Principios:** quien escribe no revisa · verificar antes de anunciar · el navegador es lo último y lo más caro · paradas humanas antes de alcance, reviews, QA y deploy.

## Arquitectura

```
Plugin (genérico, versionado acá)          Proyecto (específico, en cada repo)
─────────────────────────────────          ───────────────────────────────────
skills  → el CÓMO de cada flujo            CLAUDE.md          → QUÉ es el proyecto
agents  → reviewers / verificadores        .claude/rules/     → convenciones por path
hooks   → guardrails automáticos   ──lee──▶ .claude/metodologia.json → apps, stacks, QA, secretos
templates → punto de partida               .claude/settings.json     → permisos
```

Los hooks no saben de Rails ni de React: leen `apps[].stack` de `.claude/metodologia.json` y cargan
`hooks/adapters/<stack>.sh` (`rails`, `vitest`, `jest`, `pytest`, `custom`). Ver `hooks/adapters/README.md`.

Lo propio de cada proyecto que antes estaba dentro de los reviewers (contrato de la API, alias, librerías)
va a `.claude/rules/review-<stack>.md`, que los reviewers leen con prioridad.

## Instalar en un proyecto

Requisitos: `jq` (hooks). Opcionales: [`openspec`](https://github.com/Fission-AI/OpenSpec), `codegraph`, Node (QA visual).

```
/plugin marketplace add facundoosti/metodologia-claude      # o la ruta local: ~/Dev/metodologia-claude
/plugin install metodologia@metodologia-claude
/metodologia:inicializar
```

`inicializar` detecta el stack, pregunta lo mínimo (git/deploy, logs, QA) y genera la config del proyecto.
Agrega `enabledPlugins` + `extraKnownMarketplaces` al `settings.json` del repo para que el equipo lo tenga activo al clonar.

## Configuración por proyecto (`.claude/metodologia.json`)

Ejemplo completo en `plugins/metodologia/templates/metodologia.json`.

| Campo | Para qué |
|---|---|
| `deploy` | rama y si el push deploya (lo usan orquestar y quick-fix en la parada de commit) |
| `production` | dónde mirar logs, deploys y datos (bugbuster) |
| `apps[]` | `dir`, `stack`, `reviewer`, `test_env` (defaults), `test_env_hint`; para `custom`: `lint`, `lint_match`, `test`, `test_match`, `env_error` |
| `protect` | globs extra que no se editan |
| `secrets` | regex de secretos (bloquea edición y lectura por shell) |
| `qa` | URL, health checks, viewport, temas, clave del tema, selectores de login |

## Nombres con namespace

Las piezas del plugin se invocan con prefijo: `/metodologia:orquestar`, agente `metodologia:spec-verifier`.
Las skills de OpenSpec (`/openspec-propose`, etc.) las genera `openspec init` en cada proyecto: no vienen en el plugin.

## Desarrollo local

```
claude --plugin-dir ~/Dev/metodologia-claude/plugins/metodologia
```
