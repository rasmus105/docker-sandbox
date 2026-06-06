#!/usr/bin/env zsh

BRANCH_ARGS=()

parse_sbx_args() {
  BRANCH_ARGS=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --branch)
        BRANCH_ARGS=(--branch "$2")
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done
}

sbx_run() {
  local command_args=("$@")
  local login_exec='exec zsh -lc '\''exec "$@"'\'' zsh "$@"'
  local auth_file="$HOME/.local/share/opencode/auth.json"
  local auth_dir="${auth_file:h}"
  local auth_exec='auth_file="$1"; shift; install -d -m 700 "$HOME/.local/share/opencode"; ln -sfn "$auth_file" "$HOME/.local/share/opencode/auth.json"; exec zsh -lc '\''exec "$@"'\'' zsh "$@"'
  SANDBOX="dev-$(basename "$PWD")"
  if ! sbx ls 2>/dev/null | awk 'NR>1 {print $1}' | grep -qxF "$SANDBOX"; then
    if [[ -f "$auth_file" ]]; then
      exec sbx run --name "$SANDBOX" -t sandbox-dev "${BRANCH_ARGS[@]}" shell . "${auth_dir}:ro" -- -c "$auth_exec" sh "$auth_file" "${command_args[@]}"
    else
      print -u2 "No opencode auth found at $auth_file; skipping auth copy."
      exec sbx run --name "$SANDBOX" -t sandbox-dev "${BRANCH_ARGS[@]}" shell . -- -c "$login_exec" sh "${command_args[@]}"
    fi
  fi
  exec sbx run "$SANDBOX" "${BRANCH_ARGS[@]}" -- -c "$login_exec" sh "${command_args[@]}"
}
