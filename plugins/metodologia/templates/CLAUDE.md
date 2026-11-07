# CLAUDE.md

<!-- Plantilla de la metodología. Completá lo marcado con <…> y borrá lo que no aplique. -->

## Proyecto

<Qué es, para quién, en 2 líneas.>

```
<app>/    # <stack> → ver <app>/CLAUDE.md
```

## Comandos

```bash
<comando para levantar todo>
<comando de tests>
<comando de lint>
```

## Flujo de trabajo (plugin `metodologia`)

Features y cambios no triviales siguen OpenSpec. Artefactos en **<idioma>** (`openspec/config.yaml`).

1. `/openspec-explore` (opcional) → `/openspec-propose <idea>`
2. `/openspec-apply-change` — tests + lint antes de marcar cada task
3. Reviewers por app (`.claude/metodologia.json` → `apps[].reviewer`) sobre el diff
4. `/metodologia:qa-visual` si hay impacto visual
5. `metodologia:spec-verifier` → `/openspec-archive-change`

`/metodologia:orquestar <idea|change>` corre 2–5 de punta a punta: delega cada etapa a un sub-agente (**quien escribe no revisa**) y frena en 4 paradas (alcance, reviews, QA, commit).

Bugs: `/metodologia:bugbuster` diagnostica sin tocar código → `/metodologia:quick-fix` corrige uno acotado test-first. Registro en `docs/fixes/`.
`/metodologia:handoff` arma un bloque para seguir en otra conversación.

Fixes triviales (typos, una línea) pueden saltear OpenSpec.

## Git y deploy

- <Directo a `main` | ramas + PR>.
- <Qué dispara un push: CI, deploy a producción…>. Correr tests + lint antes de pushear; mencionar migraciones pendientes.
- Nunca force-push, `reset --hard` ni commitear archivos ajenos al cambio.

## Producción

- Logs: <dónde y cómo>.
- Datos: <acceso read-only, si existe>.

## Guardrails

- Config de la metodología: `.claude/metodologia.json` (apps, stacks, QA, secretos).
- Hooks del plugin: bloquean secretos/lockfiles/archivos generados, autocorrigen con el linter al editar y corren los tests afectados al terminar (si fallan, Claude sigue).
- Permisos en `.claude/settings.json`. Overrides personales en `.claude/settings.local.json` o `CLAUDE.local.md` (git-ignored).
- Reglas por path en `.claude/rules/` (se cargan solo al tocar esos archivos).
