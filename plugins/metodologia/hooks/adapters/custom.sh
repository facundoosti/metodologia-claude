#!/usr/bin/env bash
# Stack genérico: los comandos salen de la config de la app.
#   "lint":       "npx eslint --fix {file}"            · {file} = archivo editado
#   "lint_match": "\\.(ts|tsx)$"                        · regex (opcional)
#   "test":       "npx jest --findRelatedTests {files}" · {files} = archivos cambiados
#   "test_match": "\\.(ts|tsx)$"                        · regex (opcional)
#   "env_error":  "ECONNREFUSED|could not connect"      · regex de fallas de entorno (opcional)

adapter_lint() {
  local cmd re; cmd=$(app_cfg lint); re=$(app_cfg lint_match)
  [[ -z "$cmd" ]] && return 0
  [[ -n "$re" && ! "$1" =~ $re ]] && return 0
  bash -c "${cmd//\{file\}/$(printf '%q' "$1")}"
}

adapter_tests() {
  local cmd re env_re files=() f quoted out rc
  cmd=$(app_cfg test); re=$(app_cfg test_match); env_re=$(app_cfg env_error)
  [[ -z "$cmd" ]] && return 0
  for f in "$@"; do
    [[ -f "$f" ]] || continue
    [[ -n "$re" && ! "$f" =~ $re ]] && continue
    files+=("$f")
  done
  (( ${#files[@]} == 0 )) && return 0
  quoted=$(printf '%q ' "${files[@]}")
  out=$(bash -c "${cmd//\{files\}/$quoted}" 2>&1); rc=$?
  echo "$out" | tail -60
  (( rc == 0 )) && return 0
  [[ -n "$env_re" ]] && grep -Eq "$env_re" <<<"$out" && return 3
  return 1
}
