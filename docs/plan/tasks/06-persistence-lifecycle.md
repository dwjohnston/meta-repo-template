# Task 6: Persistence Lifecycle

Added in review. The overview promised this suite, and no task delivered it.

Add `./tests/run.sh lifecycle` that:

- Reuses the smoke fixture, with one `separate_mounts` entry and one custom persistent volume.
- Writes a sentinel file, as `vscode`, into each of the five agent-state paths, the separate mount and the custom volume.
- Writes a control file to a path that is not persisted, such as `/home/vscode/not-persisted`.
- Writes `~/.claude.json` and confirms it is a symlink into `~/.claude`.
- Recreates the container with `devcontainer up --remove-existing-container`.
- Confirms every sentinel survived, is still owned by `vscode` and is still writable.
- Confirms the control file is gone and the container ID changed.
- Cleans up exactly as Task 3 does.

Acceptance: the suite fails if any persisted volume is removed from `compose.yaml`, and fails if the entrypoint stops fixing ownership.

## Caveats

- **The control file is what makes the test honest.** Without it, a run that never recreated the container passes.
- **This is the only coverage of `docker-entrypoint.sh`.** Named volumes start owned by root; writing as `vscode` only works because the entrypoint fixes them.
- **A recreate is not a rebuild.** It reuses the image, which is what persistence needs and keeps the suite quick. A rebuild with no cache is not worth the time here.
- **Sentinels prove the volumes persist, not that conversations resume.** Agents may keep state elsewhere after an update. That is what the manual checklist is for.
- **Don't run real agents in the automated suite.** They need credentials and the network.

## Manual checklist

Run before a release, and after changing volumes, the entrypoint or the editor settings in `devcontainer.json`.

- Open the container in VS Code and start a Claude Code conversation and a Copilot conversation.
- Run "Dev Containers: Rebuild Container".
- Confirm both conversations are listed and can be resumed, and that neither agent asks to log in again.
- On a host with a Git identity, a credential helper and an SSH agent, confirm inside the container that `git config --global user.name` is empty, no credential helper is set, and `SSH_AUTH_SOCK` is unset in a VS Code terminal.

Recommended model: Claude Opus 5.5.
