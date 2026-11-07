#!/usr/bin/env bash
# SessionStart: refresca codegraph (si está) y muestra el estado del repo y de OpenSpec.
# Lo que se imprime en stdout entra como contexto de la sesión.
set -uo pipefail
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 0

command -v codegraph >/dev/null && [[ -d .codegraph ]] && codegraph sync --quiet >/dev/null 2>&1

echo "## Estado del repo"
echo "- Rama: $(git branch --show-current 2>/dev/null)"

if ! has_config; then
  echo "- ⚠️ Falta .claude/metodologia.json: los hooks de lint/tests están apagados. Corré /metodologia:inicializar."
fi

if command -v openspec >/dev/null && [[ -d openspec ]]; then
  active=$(find openspec/changes -mindepth 1 -maxdepth 1 -type d ! -name archive 2>/dev/null | xargs -n1 basename 2>/dev/null)
  if [[ -n "$active" ]]; then
    echo "- Changes de OpenSpec activos: $(echo "$active" | tr '\n' ' ')"
    echo "  Antes de implementar, leé su tasks.md y usá /openspec-apply-change (o /metodologia:orquestar)."
  else
    echo "- Sin changes de OpenSpec activos. Para features nuevas: /openspec-propose o /metodologia:orquestar."
  fi
fi
exit 0
