---
name: bugbuster
description: Diagnostica un bug o incidente sin tocar código - junta evidencia (logs de producción, código, datos), clasifica el reporte, separa confirmado de hipótesis y deja docs/fixes/<fecha>-<slug>-diagnostico.md con la propuesta de solución. Usar cuando el usuario reporte "algo anda mal", "en producción falla X", "por qué pasa Y" y la causa no esté clara. No implementa el fix → después quick-fix u openspec-propose.
argument-hint: "<síntoma, mensaje de error o reporte>"
---

# bugbuster — Diagnóstico sin fix

**Solo lectura:** no edites código ni datos. El único archivo que escribís es el diagnóstico.

Principio: **el reporte es lo que alguien vio, no lo que pasó.** La evidencia separa un diagnóstico de una hipótesis elegante.

## 1. Recopilar

Síntoma, pantalla, hora aproximada, usuario/rol afectado, captura, mensaje. Si falta algo crítico, preguntá en **una** ronda corta.

## 2. Evidencia de producción (solo lectura)

Leé `.claude/metodologia.json` → `production` (cómo ver logs, deploys y datos) y la sección de producción de `CLAUDE.md`.

- **Logs**: ventana acotada a la hora del reporte, filtrando errores/excepciones.
- **¿Coincide con un deploy?** Compará la fecha del último deploy con el inicio del síntoma.
- **Datos**: solo con el acceso read-only que indique el proyecto. Si pide permiso, es esperado.
- Anclá cada dato a **servicio + ventana + conteo**. Anonimizá datos personales.
- Si no pudiste acceder: escribí **"sin acceso a logs"** — no es lo mismo que "no aparece".

## 3. Clasificar

**Defecto confirmado** · **Comportamiento esperado** (lo dice `openspec/specs/`) · **Error de uso / dato mal cargado** · **No verificable**.

## 4. Código

`codegraph context "<síntoma>"` → `codegraph trace` del flujo (o grep + lectura si no hay codegraph). Enumerá escenarios, el más probable primero, con la evidencia que apoya o descarta cada uno.

Si quedan varias hipótesis viables: pedí **máximo 3** verificaciones concretas al usuario y anotá pedido + resultado.

## 5. Documento

`docs/fixes/YYYY-MM-DD-<slug>-diagnostico.md`:

```markdown
# Diagnóstico: <título>

## Lectura rápida
**Veredicto:** <defecto confirmado | comportamiento esperado | error de uso | no verificable>
<1–2 líneas>

## Explicación simple
<para alguien no técnico: qué pasó y qué hacer mientras tanto>

## Evidencia
- Logs: <servicio, ventana, conteo, extracto> | sin acceso a logs
- Deploy relacionado: …
- Código: `archivo:línea`

## Análisis técnico
**Confirmado:** …
**Hipótesis:** … (con qué la confirmaríamos)

## Verificaciones pedidas (si hubo)

## Propuesta de solución
<qué cambiar, sin implementar · tamaño: acotado | requiere change>
```

## 6. Siguiente paso

`AskUserQuestion` según el veredicto:
- Defecto acotado → **`/metodologia:quick-fix` con este diagnóstico (Recommended)** · `/openspec-propose` · Nada.
- Defecto grande (varias capas, migración, contrato) → **`/openspec-propose` (Recommended)** · `/metodologia:orquestar` · Nada.
- Esperado / uso / no verificable → sin código; ofrecé la explicación simple para compartir.

## Nunca

- Editar código, datos o configuración.
- Presentar una hipótesis como causa confirmada.
- Escribir en la base de producción.
