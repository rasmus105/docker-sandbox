#!/usr/bin/env bash

BRANCH_ARGS=""

parse_sbx_args() {
  BRANCH_ARGS=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --branch)
        BRANCH_ARGS="--branch $2"
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done
}

sbx_run() {
  local cmd="$1"
  SANDBOX="dev-$(basename "$PWD")"
  if ! sbx ls 2>/dev/null | awk 'NR>1 {print $1}' | grep -qxF "$SANDBOX"; then
    if [[ -n "$cmd" ]]; then
      exec sbx run --name "$SANDBOX" -t sandbox-dev $BRANCH_ARGS shell . -- -c "$cmd"
    else
      exec sbx run --name "$SANDBOX" -t sandbox-dev $BRANCH_ARGS shell .
    fi
  fi
  if [[ -n "$cmd" ]]; then
    exec sbx run "$SANDBOX" $BRANCH_ARGS -- -c "$cmd"
  else
    exec sbx run "$SANDBOX" $BRANCH_ARGS
  fi
}
