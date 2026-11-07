---
paths:
  - "backend/**/*.rb"
---

# Checklist de review (Rails) — propio del proyecto

<Lo leen `rails-reviewer` y quien implemente. Ejemplos; reemplazalos por los tuyos:>

- Respuestas de la API siempre `{ success, data, message }` o `{ success: false, errors, message }` con el status correcto.
- Serializers con Blueprinter y vistas nombradas.
- Listados paginados con Pagy.
