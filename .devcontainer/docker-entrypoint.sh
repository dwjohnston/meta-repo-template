#!/usr/bin/env bash
# Container entrypoint. Runs as root on every container start, then hands off
# to the container command (`sleep infinity` by default).
#
# 1. Named volumes are created owned by root, and volumes created before Dev
#    Containers remapped the vscode UID to the host UID are owned by the old
#    UID. Fix both so the vscode user can write to them.
# 2. Keep ~/.claude.json (a single file) persisted by symlinking it into the
#    persisted ~/.claude volume.
set -euo pipefail

# token_length() {
#     local token="${1-}"
#     printf '%s' "${#token}"
# }

# printf '[meta-repo] token lengths: GITHUB_TOKEN=%s X_GITHUB_TOKEN=%s\n' \
#     "$(token_length "${GITHUB_TOKEN-}")" \
#     "$(token_length "${X_GITHUB_TOKEN-}")"

# if [[ -n "${X_GITHUB_TOKEN:-}" ]]; then
#     export GITHUB_TOKEN="$X_GITHUB_TOKEN"
# fi

USER_NAME=vscode
USER_HOME=/home/${USER_NAME}
USER_UID=$(id -u "$USER_NAME")
USER_GID=$(id -g "$USER_NAME")

# Persisted agent-state paths (named volumes declared in compose.yaml).
AGENT_STATE_PATHS=(
    "$USER_HOME/.copilot"
    "$USER_HOME/.vscode-server/data/agentSessionData"
    "$USER_HOME/.vscode-server/data/User/globalStorage"
    "$USER_HOME/.claude"
    "$USER_HOME/.dsh"
)

# Extra volume paths (separate_mounts, persistent_volumes) come from
# compose.local.yaml as a colon-separated list.
IFS=':' read -r -a EXTRA_PATHS <<< "${META_REPO_VOLUME_PATHS:-}"

# chown the parent directories of a mount point (non-recursively) up to, but
# not including, $USER_HOME or /workspace. Docker creates missing parents as root.
fix_parents() {
    local dir
    dir=$(dirname "$1")
    while [[ "$dir" == "$USER_HOME"/* || "$dir" == /workspace/* ]]; do
        if [[ -d "$dir" && "$(stat -c %u "$dir")" != "$USER_UID" ]]; then
            chown "$USER_UID:$USER_GID" "$dir"
        fi
        dir=$(dirname "$dir")
    done
}

# Recursively chown a volume only when its root isn't owned by vscode, so
# large caches aren't re-walked on every start.
fix_volume() {
    local path=$1
    [[ -n "$path" ]] || return 0
    mkdir -p "$path"
    fix_parents "$path"
    if [[ "$(stat -c %u "$path")" != "$USER_UID" || "$(stat -c %g "$path")" != "$USER_GID" ]]; then
        echo "[meta-repo] fixing ownership of $path"
        chown -R "$USER_UID:$USER_GID" "$path"
    fi
}

for p in "${AGENT_STATE_PATHS[@]}" "${EXTRA_PATHS[@]}"; do
    fix_volume "$p"
done

# /workspace itself is not a mount, but may be left with a stale UID after
# Dev Containers remaps the vscode UID. /workspace/.claude is created by Docker
# as root, as the parent of the .claude/skills mount.
chown "$USER_UID:$USER_GID" /workspace
[[ -d /workspace/.claude ]] && chown "$USER_UID:$USER_GID" /workspace/.claude

# ~/.claude.json -> ~/.claude/.claude.json
claude_json="$USER_HOME/.claude.json"
claude_json_persisted="$USER_HOME/.claude/.claude.json"
if [[ -f "$claude_json" && ! -L "$claude_json" ]]; then
    # A regular file: either baked into the image at build time, or the symlink
    # was replaced by an atomic write during a previous run of this container.
    # Keep whichever copy is newer.
    if [[ ! -e "$claude_json_persisted" || "$claude_json" -nt "$claude_json_persisted" ]]; then
        mv "$claude_json" "$claude_json_persisted"
    else
        rm -f "$claude_json"
    fi
fi
ln -sfn "$claude_json_persisted" "$claude_json"
chown -h "$USER_UID:$USER_GID" "$claude_json"
[[ -e "$claude_json_persisted" ]] && chown "$USER_UID:$USER_GID" "$claude_json_persisted"

# Trust the repositories mounted under /workspace. They are bind-mounted from
# the host and owned by the host UID, which differs from vscode (especially on
# macOS, where updateRemoteUserUID is a no-op). Git would otherwise refuse to
# touch them with "detected dubious ownership in repository". The `*` wildcard
# would trust everything; scoping to /workspace keeps the relaxation minimal.
# Idempotent across restarts.
if ! runuser -u "$USER_NAME" -- env HOME="$USER_HOME" \
        git config --global --get-all safe.directory 2>/dev/null | grep -qx /workspace; then
    runuser -u "$USER_NAME" -- env HOME="$USER_HOME" \
        git config --global --add safe.directory /workspace
fi

# Configure Git for the container user without contacting GitHub or storing a
# token. gh reads GITHUB_TOKEN (or GH_TOKEN) when Git requests credentials.
# This is also safe when no token is set: only authenticated Git operations fail.
if [ -z "${GITHUB_TOKEN:-}" ]; then
    echo "[meta-repo] GITHUB_TOKEN not set; skipping GitHub auth setup" >&2
elif ! runuser -u "$USER_NAME" -- env HOME="$USER_HOME" bash -c '
    # 1. Store the token as a persistent gh login. Clear the env vars for this
    #    one call, because gh refuses to store credentials while they are set.
    #    A failure here is non-fatal.
    printf %s "$GITHUB_TOKEN" \
        | env -u GITHUB_TOKEN -u GH_TOKEN \
            gh auth login --hostname github.com --with-token --insecure-storage \
        || echo "[meta-repo] warning: gh auth login failed" >&2

    # 2. Git config: HTTPS via gh credential helper, rewrite SSH URLs
    set -e
    git config --global --replace-all credential.https://github.com.helper ""
    git config --global --add credential.https://github.com.helper "!gh auth git-credential"
    git config --global --replace-all url.https://github.com/.insteadOf "git@github.com:"
    git config --global --add url.https://github.com/.insteadOf "ssh://git@github.com/"
'; then
    echo "[meta-repo] warning: GitHub Git setup failed; continuing startup" >&2
fi

exec "$@"
