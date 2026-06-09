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

  local opencode_auth_file="$HOME/.local/share/opencode/auth.json"
  local claude_auth_file="$HOME/.local/share/claude-code/auth.json"

  local has_opencode=false
  local has_claude=false
  [[ -f "$opencode_auth_file" ]] && has_opencode=true
  [[ -f "$claude_auth_file" ]] && has_claude=true

  local auth_exec='
    opencode_auth="$1"; claude_auth="$2"; shift 2
    if [[ -n "$opencode_auth" && -f "$opencode_auth" ]]; then
      install -d -m 700 "$HOME/.local/share/opencode"
      ln -sfn "$opencode_auth" "$HOME/.local/share/opencode/auth.json"
    fi
    if [[ -n "$claude_auth" && -f "$claude_auth" ]]; then
      api_key="$(jq -r .apiKey "$claude_auth" 2>/dev/null)"
      if [[ -n "$api_key" && "$api_key" != "null" ]]; then
        export ANTHROPIC_API_KEY="$api_key"
      fi
    fi
    exec zsh -lc '\''exec "$@"'\'' zsh "$@"
  '

  SANDBOX="dev-$(basename "$PWD")"
  if ! sbx ls 2>/dev/null | awk 'NR>1 {print $1}' | grep -qxF "$SANDBOX"; then
    if $has_opencode || $has_claude; then
      local mounts=()
      if $has_opencode; then
        mounts+=("${opencode_auth_file:h}:ro")
      fi
      if $has_claude; then
        mounts+=("${claude_auth_file:h}:ro")
      fi
      local opencode_arg="$([[ $has_opencode ]] && echo "$opencode_auth_file" || echo "")"
      local claude_arg="$([[ $has_claude ]] && echo "$claude_auth_file" || echo "")"
      exec sbx run --name "$SANDBOX" -t sandbox-dev "${BRANCH_ARGS[@]}" shell . "${mounts[@]}" -- -c "$auth_exec" sh "$opencode_arg" "$claude_arg" "${command_args[@]}"
    else
      print -u2 "No opencode or claude auth found; skipping auth copy."
      exec sbx run --name "$SANDBOX" -t sandbox-dev "${BRANCH_ARGS[@]}" shell . -- -c "$login_exec" sh "${command_args[@]}"
    fi
  fi
  exec sbx run "$SANDBOX" "${BRANCH_ARGS[@]}" -- -c "$login_exec" sh "${command_args[@]}"
}
