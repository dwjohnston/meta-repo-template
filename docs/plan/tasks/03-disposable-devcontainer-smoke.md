# Task 3: Disposable Dev Container Smoke Test

Add `./tests/run.sh smoke` that:

- Reuses the isolated fixture setup.
- Bootstraps a pinned standalone Dev Container CLI.
- Runs `devcontainer up --frozen-lockfile`.
- Confirms a container ID, the `vscode` remote user, `/workspace`, and the fixture repository mount.
- Cleans up only the test container and its uniquely named volumes.

Tool, Git, Docker-in-Docker, and persistence checks remain separate tasks.

## Caveats

- **`--frozen-lockfile` is real, but recent.** It exists in `@devcontainers/cli` 0.90.0; older releases only had `--experimental-frozen-lockfile`. Pin 0.90.0 or later.
- **"Standalone" needs deciding.** The CLI ships as an npm package and needs Node on the host. Either require Node and install the pinned version into a cache directory outside the repo, or use the upstream install script that bundles Node. The first is simpler and matches CI runners.
- **Use a unique project name per run.** Fixed `metarepo_id` such as `mrtest`, plus a per-run `metarepo_suffix`. Both must be lowercase letters, digits, `-` or `_`.
- **The fixture must publish no ports**, or the test container fights the developer's container for `127.0.0.1:13000` and the rest.
- **Check the user with `devcontainer exec`.** The container itself runs as root, because the entrypoint needs root. `docker exec ... whoami` reports `root` and is the wrong test.
- **Cleanup needs three things:** the container, the volumes and the image. Use `docker compose -p <project> down --volumes --rmi local`. The Dev Container CLI has no `down` command.
- **Guard the cleanup.** Refuse to run it unless the project name starts with the test prefix. Put it in a trap that also fires on failure and interrupt.
- **Sweep leftovers from crashed runs** by filtering on the test prefix at the start of each run.
- **The first build is slow and needs the network.** Layer cache makes later runs quicker, but there's no cache on a fresh CI runner. Set a generous timeout and print progress.
- **The Docker-in-Docker feature makes the container privileged.** This works on GitHub's Linux runners. It won't work on rootless or otherwise restricted Docker hosts; detect that and report it clearly.
- **Don't pass `GITHUB_TOKEN` into the fixture.** With a token the entrypoint logs in to `gh` and writes a credential helper, which would contaminate Task 5.
- **Running smoke from inside the dev container** (admin mode, through its inner Docker daemon) should work, because the fixture path is visible to that daemon. This is untested.

Recommended model: Claude Opus 5.5.
