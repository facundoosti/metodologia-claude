---
name: orquestar
description: Lleva una feature de punta a punta por el flujo OpenSpec (propose → apply → reviews → QA visual → spec-verifier → archive → commit), delegando cada tramo a un sub-agente y frenando en 4 paradas con AskUserQuestion. Usar cuando el usuario pida "orquestar", "llevá esto hasta el final", "hacé la feature completa" o retome un change a medias. No usar para un bug acotado → quick-fix, ni para diagnosticar → bugbuster.
argument-hint: "<idea de la feature> | <nombre de change existente>"
---

# orquestar — Coordinar una feature de punta a punta

Vos **coordinás**: decidís la etapa, delegás, verificás y preguntás. No implementás lo que delegaste.

Config del proyecto: `.claude/metodologia.json` (apps, reviewer de cada una, rama de deploy, QA). Si no existe, frená y sugerí `/metodologia:inicializar`.

## Principios (no negociables)

- **Quien escribe no revisa.** El sub-agente que modificó código nunca revisa ese código.
- **Verificar antes de anunciar.** Lo que declara un sub-agente se comprueba (`git diff`, `tasks.md`, tests).
- **Una sola ronda de correcciones** después de los reviews.
- **No inventar estado**: change, tests, rama o commit se consultan, no se recuerdan.
- **Si `deploy.push_deploys` es true, push a `deploy.branch` = deploy a producción.** Nunca se pushea sin la parada 4.
- **No ampliar alcance.** Lo que aparezca fuera del change va a "Pendientes".

## Mapa de estado

Después de cada etapa, mostrá solo esto:

```
🧭 <change>  ·  rama: <git branch --show-current>
✅ propose   ✅ apply   ⏳ reviews   ·  qa   ·  verify   ·  archive   ·  commit
Último: <resultado verificable en 1 línea>
Próximo: <etapa>
Pendientes: <fuera de alcance / N/A con razón>
```

Una etapa que no aplica queda `N/A` con la razón (ej. `qa: N/A — sin UI`).

## Paso 0 — Detectar dónde estamos

1. `git branch --show-current` y `git status --short`. Si la rama no coincide con el flujo de git de `CLAUDE.md`, avisalo en el mapa.
2. `openspec list`. Si el argumento es un change existente, leé su `tasks.md` y entrá en la etapa más atrasada: sin tasks marcadas → apply · todas `[x]` → reviews · archivado → commit.
3. Si es una idea nueva → etapa 1.

## Etapa 1 — Propose (hilo principal)

Corré `/openspec-propose <idea>` en este hilo (puede necesitar preguntar cosas).

### 🛑 Parada 1 — Alcance

`AskUserQuestion` con resumen de 2–3 líneas del proposal y cantidad de tasks; decí **por qué importa**: corregir alcance acá es lo más barato.
Opciones: **Aprobar y construir** · **Ajustar** · **Cancelar**.

## Etapa 2 — Apply (sub-agente)

`Agent` (`general-purpose`) con un paquete autocontenido:

```
Objetivo: implementar el change de OpenSpec <change> siguiendo la skill openspec-apply-change
Leé antes: CLAUDE.md, el CLAUDE.md de cada app tocada, .claude/metodologia.json, openspec/changes/<change>/*
Reglas: tests + lint antes de marcar cada task; no commitear; no pushear; no tocar nada fuera del change.
Devolvé: tasks marcadas, archivos tocados, comandos de test/lint con resultado, migraciones nuevas, dudas.
```

**Verificá** al volver: `git diff --stat`, `tasks.md`, y corré los tests afectados. Si algo no coincide, decilo y no avances.

## Etapa 3 — Reviews (sub-agentes en paralelo)

Por cada app tocada por el diff, lanzá su `reviewer` (de `apps[].reviewer`; los agentes del plugin se llaman `metodologia:<nombre>`) **en un mismo mensaje**.

### 🛑 Parada 2 — Hallazgos

Agrupá por severidad (bloqueante / sugerencia / nit) y preguntá:
- **Bloqueantes + sugerencias (Recommended)** · **Solo bloqueantes** · **Todo, incluidos nits** · **Nada**.
- Con ≤ 4 hallazgos relevantes, `multiSelect: true` listándolos uno por uno.
- Cada opción con una línea de **por qué**.

## Etapa 3b — Una ronda de fixes (sub-agente nuevo)

`Agent` (`general-purpose`) **nuevo** con la lista exacta (`archivo:línea` + qué cambiar). Al volver, **vos** verificás el diff y corrés los tests. Sin segunda review completa.

## Etapa 4 — QA visual (si hay impacto visual)

Si el diff toca UI → `/metodologia:qa-visual`. Si no → `qa: N/A` con razón y saltá la parada.

### 🛑 Parada 3 — Resultado de QA

Conteo pass/fail de casos `must`. Opciones: **Seguir** · **Corregir fallos** (sub-agente nuevo + re-correr solo los afectados) · **Aceptar fallo y seguir** (va a Pendientes).

## Etapa 5 — Verificación de specs

`metodologia:spec-verifier` con el nombre del change. Si hay ❌: un sub-agente nuevo corrige y se re-verifica **una vez**.

## Etapa 6 — Archive

`/openspec-archive-change <change>` en el hilo principal.

## Etapa 7 — Commit

### 🛑 Parada 4 — Commit y deploy

Antes de preguntar:
- `git status --short`, separando archivos del change de los ajenos (pids, configs personales): **nunca** entran.
- **Migraciones nuevas** → avisá que corren en el deploy.
- Lint y tests afectados en verde (si no, decilo).

Opciones: **Commit + push (deploy)** · **Solo commit** · **No commitear todavía**. Recordá qué dispara el push.

Commit convencional (`feat:`, `fix:`…) en el idioma del proyecto, solo con los archivos del change.

## Final

Mapa completo + 1 párrafo humano de qué quedó hecho + Pendientes. Si se corta a mitad, ofrecé `/metodologia:handoff`.

## Nunca

- Implementar en el hilo principal lo que se delegó.
- Revisar código con el mismo agente que lo escribió.
- Pushear sin la parada 4, `reset --hard`, force-push o resetear la DB.
- Saltar una parada porque "parece obvio".
