#!/usr/bin/env bash
# Python: ruff al editar; pytest sobre tests cambiados o test_<modulo>.py correspondientes.

adapter_lint() {
  [[ "$1" == *.py ]] || return 0
  ruff check --fix "$1" && ruff format "$1" >/dev/null
}

adapter_tests() {
  local tests=() f base out rc
  for f in "$@"; do
    [[ "$f" == *.py ]] || continue
    base=$(basename "$f" .py)
    if [[ "$base" == test_* ]]; then
      [[ -f "$f" ]] && tests+=("$f")
    else
      while IFS= read -r t; do tests+=("$t"); done < <(find . -path ./node_modules -prune -o -name "test_${base}.py" -print 2>/dev/null)
    fi
  done
  (( ${#tests[@]} == 0 )) && return 0
  out=$(pytest -q $(printf '%s\n' "${tests[@]}" | sort -u) 2>&1); rc=$?
  echo "$out" | tail -60
  (( rc == 0 )) && return 0
  grep -Eq 'OperationalError|could not connect|Connection refused' <<<"$out" && return 3
  return 1
}
