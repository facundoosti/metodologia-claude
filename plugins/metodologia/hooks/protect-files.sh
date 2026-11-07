#!/usr/bin/env bash
# PreToolUse (Edit|Write): bloquea la edición de secretos, lockfiles y archivos generados.
# Base fija + globs extra en .claude/metodologia.json → "protect" (y regex en "secrets").
set -euo pipefail
source "$(dirname "$0")/lib.sh"

file_path=$(jq -r '.tool_input.file_path // empty')
[[ -z "$file_path" ]] && exit 0

block() { echo "Bloqueado: $1" >&2; exit 2; }

case "$file_path" in
  */.env.example|*/.env.sample) exit 0 ;;
  */.env|*/.env.*) block "$file_path contiene secretos. Pedile al usuario que lo edite manualmente." ;;
  */db/schema.rb|*/db/structure.sql) block "no edites el schema generado. Generá una migración." ;;
  */Gemfile.lock|*/package-lock.json|*/yarn.lock|*/pnpm-lock.yaml|*/poetry.lock|*/uv.lock|*/composer.lock)
    block "los lockfiles se regeneran con el gestor de paquetes, no se editan a mano." ;;
  */.codegraph/*|*/openspec/changes/archive/*) block "$file_path es generado/archivado y no se edita a mano." ;;
esac

if has_config; then
  while IFS= read -r re; do
    [[ -n "$re" && "$file_path" =~ $re ]] && block "$file_path coincide con un secreto configurado ($re)."
  done < <(jq -r '.secrets // [] | .[]' "$CONFIG")
  while IFS= read -r glob; do
    # shellcheck disable=SC2053
    [[ -n "$glob" && "$file_path" == $glob ]] && block "$file_path está protegido en .claude/metodologia.json ($glob)."
  done < <(jq -r '.protect // [] | .[]' "$CONFIG")
fi
exit 0
