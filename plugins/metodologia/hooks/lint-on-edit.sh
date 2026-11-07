#!/usr/bin/env bash
# PostToolUse (Edit|Write): autocorrige el archivo editado con el linter de su app
# y devuelve a Claude los errores que queden. Usa el adapter del stack de cada app.
set -uo pipefail
source "$(dirname "$0")/lib.sh"
has_config || exit 0

file_path=$(jq -r '.tool_input.file_path // empty')
[[ -z "$file_path" || ! -f "$file_path" ]] && exit 0

n=$(apps_count)
for ((APP_INDEX = 0; APP_INDEX < n; APP_INDEX++)); do
  prefix=$(app_prefix)
  [[ "$file_path" == "$prefix"* ]] || continue
  rel="${file_path#"$prefix"}"
  out=$(
    load_adapter "$(app_cfg stack)" || exit 0
    cd "$prefix" && adapter_lint "$rel" 2>&1
  )
  if [[ $? -ne 0 ]]; then
    echo "El linter dejó errores en $rel:" >&2
    echo "$out" | tail -40 >&2
    exit 2
  fi
  exit 0
done
exit 0
