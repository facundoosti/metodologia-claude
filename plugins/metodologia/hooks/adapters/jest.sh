#!/usr/bin/env bash
# JS/TS con Jest: ESLint al editar; `jest --findRelatedTests` sobre lo cambiado.
source "$(dirname "${BASH_SOURCE[0]}")/vitest.sh"

adapter_tests() {
  local files=() f out rc
  for f in "$@"; do _fe_match "$f" && [[ -f "$f" ]] && files+=("$f"); done
  (( ${#files[@]} == 0 )) && return 0
  out=$(npx --no-install jest --findRelatedTests --passWithNoTests "${files[@]}" 2>&1); rc=$?
  echo "$out" | tail -60
  (( rc == 0 )) || return 1
}
