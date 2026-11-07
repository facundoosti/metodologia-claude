#!/usr/bin/env bash
# PreToolUse (Bash): cubre lo que las reglas deny de Read no ven (cat/grep sobre secretos).
set -euo pipefail
source "$(dirname "$0")/lib.sh"

cmd=$(jq -r '.tool_input.command // empty')
[[ -z "$cmd" ]] && exit 0

if grep -Eq '(^|[[:space:]/"'"'"'])\.env(\.[A-Za-z0-9_-]+)?([[:space:]"'"'"';|&]|$)' <<<"$cmd" \
   && ! grep -Eq '\.env\.(example|sample)' <<<"$cmd"; then
  echo "Bloqueado: el comando toca un archivo .env con secretos. Usá .env.example o pedile el valor al usuario." >&2
  exit 2
fi

if has_config; then
  while IFS= read -r re; do
    if [[ -n "$re" ]] && grep -Eq "$re" <<<"$cmd"; then
      echo "Bloqueado: el comando toca un secreto configurado ($re)." >&2
      exit 2
    fi
  done < <(jq -r '.secrets // [] | .[]' "$CONFIG")
fi
exit 0
