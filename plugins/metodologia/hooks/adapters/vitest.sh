#!/usr/bin/env bash
# Frontend JS/TS con Vite: ESLint al editar; `vitest related` sobre lo cambiado.
# Campo opcional de la app: "src" (default "src").

_fe_match() {
  local src; src=$(app_cfg src); src="${src:-src}"
  [[ "$1" == "$src"/* ]] && [[ "$1" =~ \.(js|jsx|ts|tsx|mjs|cjs|vue|svelte)$ ]]
}

adapter_lint() {
  _fe_match "$1" || return 0
  npx --no-install eslint --fix "$1"
}

adapter_tests() {
  local files=() f out rc
  for f in "$@"; do _fe_match "$f" && [[ -f "$f" ]] && files+=("$f"); done
  (( ${#files[@]} == 0 )) && return 0
  out=$(npx --no-install vitest related --run --passWithNoTests "${files[@]}" 2>&1); rc=$?
  echo "$out" | tail -60
  (( rc == 0 )) || return 1
}
