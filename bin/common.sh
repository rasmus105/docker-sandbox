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

copy_opencode_auth() {
  local sandbox="$1"
  local auth_file="$HOME/.local/share/opencode/auth.json"
  local sandbox_auth_dir="/home/agent/.local/share/opencode"

  if [[ ! -f "$auth_file" ]]; then
    print -u2 "No opencode auth found at $auth_file; skipping auth copy."
    return 0
  fi

  sbx exec -u root "$sandbox" mkdir -p "$sandbox_auth_dir"
  sbx cp "$auth_file" "$sandbox:$sandbox_auth_dir/auth.json"
  sbx exec -u root "$sandbox" chown -R agent:agent "$sandbox_auth_dir"
  sbx exec -u root "$sandbox" chmod 700 "$sandbox_auth_dir"
  sbx exec -u root "$sandbox" chmod 600 "$sandbox_auth_dir/auth.json"
}

sbx_run() {
  local command_args=("$@")
  local login_exec='exec zsh -lc '\''exec "$@"'\'' zsh "$@"'
  SANDBOX="dev-$(basename "$PWD")"
  if ! sbx ls 2>/dev/null | awk 'NR>1 {print $1}' | grep -qxF "$SANDBOX"; then
    sbx create --name "$SANDBOX" -t sandbox-dev "${BRANCH_ARGS[@]}" shell .
    copy_opencode_auth "$SANDBOX"
  fi
  exec sbx run "$SANDBOX" "${BRANCH_ARGS[@]}" -- -c "$login_exec" sh "${command_args[@]}"
}
