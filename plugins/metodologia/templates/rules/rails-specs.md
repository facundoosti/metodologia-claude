---
paths:
  - "backend/spec/**/*.rb"
---

# Tests backend (RSpec)

- Endpoints como **request specs** (`spec/requests/...`), no controller specs.
- Verificá siempre el contrato de respuesta del proyecto.
- Por endpoint: caso feliz, sin auth (401), params inválidos (422) y recurso inexistente (404).
- Datos con FactoryBot; preferí `build`/`build_stubbed` cuando no hace falta persistir.
- Service specs: un `context` por rama.
- Nunca llames APIs externas reales: mockeadas.
- Correr un archivo: `cd backend && bundle exec rspec spec/ruta/al_spec.rb`.
