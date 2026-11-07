---
paths:
  - "frontend/src/**/*.jsx"
  - "frontend/src/**/*.tsx"
  - "frontend/src/**/*.css"
---

# UI (design system)

<Completá con el design system del proyecto. Ejemplo de estructura:>

- **Tokens semánticos, nunca colores crudos** (hex o paleta fija) para superficies y texto: `<bg-surface>`, `<text-on-surface>`, `<border-outline>`…
- Tema claro/oscuro: <cómo se aplica (clase en `<html>`, store…)>. No uses variantes manuales por tema si los tokens ya cambian solos.
- Patrones: card `<clases>`, botón primario `<clases>`, input `<clases>`.
- Pantalla de referencia: <ej. desktop 1440×900>.
- Reutilizá primitivas de `<carpeta de UI>` antes de crear nuevas.
