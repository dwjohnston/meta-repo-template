# Task 4: Installed-Tool Contract

Extend `./tests/run.sh smoke` with a separate container-side tool check covering:

- `git`, `gh`, `node`, `npm`, `nvm`, `bun`, `claude`, and `codex`;
- `dsh`, `pnpm`, and `python3`;
- the Docker client and Docker Compose;
- the global npm packages `@types/bun`, `@typesafe-ai/sdk` and `git-checkout-interactive` (check with `npm ls -g`).

Each tool must resolve and run a lightweight version command. Do not require authentication, network access, or exact versions. Functional Docker-in-Docker remains separate.

## Caveats

- **`nvm` is a shell function, not a binary.** `command -v nvm` fails in a plain non-interactive shell. Run the checks through `bash -lc`, which loads `/etc/profile.d/nvm.sh`.
- **Run as `vscode` through `devcontainer exec`.** Most tools live under `/home/vscode`, and running as root tests a different `PATH` and home.
- **The Docker checks must be client-only.** `docker --version` and `docker compose version` work without a daemon. `docker info` and `docker version` contact it and belong to Task 95.
- **`flyctl` and `nano` are installed but not listed.** Add them, or note that they're left out on purpose.
- **Confirm each version command by hand first.** `dsh` and `codex` in particular must not prompt, need a login, or write state into a persisted volume.
- **`npm ls -g <packages>` exits non-zero when one is missing**, which is the assertion. It reads the default Node's global directory, so it also needs the login shell.
- **Keep the tool list in one data file.** Repos made from this template will change their tools, and a single list is easier to edit than assertions spread through a script. `AGENTS.md` only requires bun, nvm, gh and claude; the rest are this repo's additions.
- **"No network access" applies to the checks only.** Building the image needs the network and installs the latest versions, so this task can fail because of an upstream release.
- **Report every missing tool in one run**, not just the first.

Recommended model: Claude Sonnet 5.5.
