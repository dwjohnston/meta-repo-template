# Task 5: Git Identity and Credential Isolation

Extend `./tests/run.sh smoke` with an offline Git contract:

- Assert the configured test name and email.
- Create a temporary repository and verify a commit uses that identity.
- Confirm host Git identity and credential-helper settings were not copied in.
- Confirm `SSH_AUTH_SOCK`, `GIT_ASKPASS`, and `SSH_ASKPASS` are unset.

GitHub login, URL rewriting, credential helpers, and remote access remain separate tasks.

## Caveats

- **Two of the four checks prove nothing under the Dev Container CLI.** The CLI never copies the host `.gitconfig`, never installs a credential helper and never forwards an SSH agent. VS Code does those things, and the settings that stop it sit under `customizations.vscode`, which the CLI ignores. "Not copied in" and "unset" pass even if those settings are deleted.
- **What can be automated instead:** assert, in the config suite, that `devcontainer.json` still contains `dev.containers.copyGitConfig: false`, `dev.containers.gitCredentialHelperConfigLocation: "none"`, `git.useIntegratedAskPass: false`, `git.terminalAuthentication: false` and the three `remoteEnv` nulls. The file has comments, so it needs a JSONC-tolerant read, for example `devcontainer read-configuration`.
- **What stays manual:** opening the container in VS Code on a host that has a Git identity, a credential helper and an SSH agent, then checking none arrived. Add it to the manual checklist in Task 6.
- **Keep the runtime checks anyway.** They're cheap and guard against something in the image or entrypoint setting these values.
- **The identity comes from `GIT_CONFIG_*` environment variables**, not from a file. Assert `git config user.name` returns the test name and `git config --global user.name` returns nothing.
- **Don't assert that `~/.gitconfig` is absent.** The entrypoint always writes `safe.directory = /workspace` there.
- **Give the fixture its own `git.name` and `git.email`**, distinct from the committed bot identity and from anything on the host.
- **Create the temporary repository outside `/workspace`**, for example under `/tmp`, so the commit check doesn't lean on the `safe.directory` exemption.
- **Check the credential helper at every scope**, with `git config --show-origin --get-all credential.helper`. It must be empty when no token is supplied.
- **`remoteEnv` only applies through `devcontainer exec`.** Check the three variables there, not with `docker exec`.

Recommended model: Claude Sonnet 5.5.
