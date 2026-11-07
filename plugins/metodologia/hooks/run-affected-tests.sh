#!/usr/bin/env bash
# Stop: corre los tests afectados por los cambios sin commitear, app por app.
# Si fallan, Claude sigue trabajando. Si falla el entorno (DB caída, etc.), avisa sin bloquear.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

input=$(cat)
[[ "$(jq -r '.stop_hook_active // false' <<<"$input")" == "true" ]] && exit 0
has_config || exit 0
cd "$ROOT" || exit 0

changed=$( { git diff --name-only HEAD; git ls-files --others --exclude-standard; } 2>/dev/null | sort -u )
[[ -z "$changed" ]] && exit 0

# No repetir si los cambios no se modificaron desde la última corrida verde.
state_file="${TMPDIR:-/tmp}/claude-metodologia-tests-$(echo "$ROOT" | shasum | cut -c1-8)"
state=$( { git diff HEAD; git ls-files --others --exclude-standard | xargs cat 2>/dev/null; } | shasum | cut -c1-40 )
[[ -f "$state_file" && "$(cat "$state_file")" == "$state" ]] && exit 0

failures=""
warnings=""
n=$(apps_count)
for ((APP_INDEX = 0; APP_INDEX < n; APP_INDEX++)); do
  prefix=$(app_prefix)
  rel_prefix="${prefix#"$ROOT/"}"
  files=()
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    [[ -z "$rel_prefix" || "$f" == "$rel_prefix"* ]] && files+=("${f#"$rel_prefix"}")
  done <<<"$changed"
  (( ${#files[@]} == 0 )) && continue

  name=$(app_cfg name); name="${name:-$(app_cfg dir)}"
  out=$(
    load_adapter "$(app_cfg stack)" || exit 0
    export_app_env
    cd "$prefix" && adapter_tests "${files[@]}" 2>&1
  )
  rc=$?
  case $rc in
    0) ;;
    3) hint=$(app_cfg test_env_hint)
       warnings+="⚠️ Los tests de $name no pudieron correr por el entorno.${hint:+ Probá: $hint} " ;;
    *) failures+=$'\n### '"$name"$'\n'"$(echo "$out" | tail -60)" ;;
  esac
done

[[ -n "$warnings" ]] && jq -n --arg m "$warnings" '{systemMessage: $m}'

if [[ -n "$failures" ]]; then
  echo "Hay tests fallando por los cambios actuales. Corregilos antes de terminar:$failures" >&2
  exit 2
fi

[[ -z "$warnings" ]] && echo "$state" > "$state_file"
exit 0
