#!/usr/bin/env bash
# Rails: RuboCop al editar; RSpec mapeando app/**/x.rb → spec/**/x_spec.rb.

adapter_lint() {
  case "$1" in
    db/schema.rb) return 0 ;;
    *.rb|*.rake) bundle exec rubocop -a --format simple --force-exclusion "$1" ;;
  esac
}

adapter_tests() {
  local specs=() existing=() rel base sub rest out rc
  for rel in "$@"; do
    case "$rel" in
      spec/*_spec.rb) specs+=("$rel") ;;
      app/controllers/*_controller.rb)
        base="${rel#app/controllers/}"; base="${base%_controller.rb}"
        specs+=("spec/requests/${base}_spec.rb" "spec/controllers/${base}_controller_spec.rb") ;;
      app/*.rb|lib/*.rb)
        base="${rel#app/}"; base="${base#lib/}"; base="${base%.rb}"
        sub="${base%%/*}"; rest="${base#*/}"
        specs+=("spec/${sub}/${rest}_spec.rb") ;;
    esac
  done
  for rel in "${specs[@]:-}"; do [[ -n "$rel" && -f "$rel" ]] && existing+=("$rel"); done
  (( ${#existing[@]} == 0 )) && return 0

  out=$(bundle exec rspec $(printf '%s\n' "${existing[@]}" | sort -u) --format progress 2>&1); rc=$?
  echo "$out" | tail -60
  (( rc == 0 )) && return 0
  grep -Eq 'PendingMigrationError|could not connect|NoDatabaseError|connection to server' <<<"$out" && return 3
  return 1
}
