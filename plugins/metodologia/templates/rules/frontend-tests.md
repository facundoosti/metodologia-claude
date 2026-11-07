---
paths:
  - "frontend/src/**/__tests__/**"
  - "frontend/src/**/*.test.{js,jsx,ts,tsx}"
---

# Tests frontend

- Testeá comportamiento visible (roles, textos, interacciones con `userEvent`), no detalles de implementación.
- Usá el helper de render con providers del proyecto (QueryClient, Router…) en vez de `render` plano.
- Mockeá la capa de servicios; nunca peguen al backend real.
- Cubrí los estados cargando, error y vacío de cada componente que consume datos.
