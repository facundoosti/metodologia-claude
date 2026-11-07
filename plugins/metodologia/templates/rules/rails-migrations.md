---
paths:
  - "backend/db/**"
  - "backend/app/models/**/*.rb"
---

# Base de datos y migraciones

- **Nunca** edites el schema generado (`db/schema.rb`; hay un hook que lo bloquea). Generá una migración: `bin/rails g migration NombreDescriptivo`.
- Toda migración es reversible (`change` o `up`/`down`).
- Índices para foreign keys y columnas usadas en filtros/búsquedas.
- Columnas `null: false` en tablas con datos necesitan default o backfill en la misma migración.
- Correr migraciones requiere confirmación del usuario; dropear/resetear la DB está prohibido para Claude.
