#!/usr/bin/env bash
# Helpers compartidos por los hooks. Toda la parte específica del proyecto vive en
# .claude/metodologia.json; sin ese archivo, los hooks dependientes del stack no hacen nada.

ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
CONFIG="$ROOT/.claude/metodologia.json"
HOOKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

has_config() { [[ -f "$CONFIG" ]] && command -v jq >/dev/null; }

# cfg '<jq path>' → valor o vacío
cfg() { has_config && jq -r "$1 // empty" "$CONFIG" 2>/dev/null; }

apps_count() { has_config && jq '.apps | length' "$CONFIG" 2>/dev/null || echo 0; }

# app_cfg <campo> → campo de la app actual (APP_INDEX)
app_cfg() { jq -r ".apps[${APP_INDEX}].$1 // empty" "$CONFIG"; }

# Prefijo absoluto de la app (soporta dir ".")
app_prefix() {
  local dir; dir=$(app_cfg dir)
  if [[ -z "$dir" || "$dir" == "." ]]; then echo "$ROOT/"; else echo "$ROOT/${dir%/}/"; fi
}

# Exporta test_env de la app como defaults (no pisa variables ya definidas).
export_app_env() {
  local k v
  while IFS=$'\t' read -r k v; do
    [[ -z "$k" ]] && continue
    [[ -z "${!k:-}" ]] && export "$k=$v"
  done < <(jq -r ".apps[${APP_INDEX}].test_env // {} | to_entries[] | [.key, .value] | @tsv" "$CONFIG")
}

# Carga el adapter del stack (define adapter_lint / adapter_tests).
load_adapter() {
  local f="$HOOKS_DIR/adapters/$1.sh"
  [[ -f "$f" ]] || return 1
  # shellcheck disable=SC1090
  source "$f"
}
