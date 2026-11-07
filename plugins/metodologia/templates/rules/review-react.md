---
paths:
  - "frontend/src/**"
---

# Checklist de review (React) — propio del proyecto

<Lo leen `react-reviewer` y quien implemente. Ejemplos; reemplazalos por los tuyos:>

- Imports siempre con alias (`@ui`, `@services`, `@hooks`), nunca rutas relativas.
- Llamadas a la API solo con hooks de TanStack Query en `src/services/`.
- Container (lógica) + View (render); estado global solo en Zustand; toasts vía `notificationService`.
