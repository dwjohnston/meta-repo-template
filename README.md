# meta-repo template

Open several repositories together in one dev container, with Docker-in-Docker,
Node (nvm), bun, gh and the Claude Code CLI preinstalled. Agent conversations
(Claude Code, Copilot / VS Code chat) survive container rebuilds.

Inside the container:

```
/workspace/
    AGENTS.md / CLAUDE.md   # instructions for agents (from .root/)
    .agents/skills/         # shared skills (also at /workspace/.claude/skills)
    .workspace/             # read-only Dockerfile, devcontainer.json, compose.yaml
    foo/                    # your repos
    bar/
    meta-repo-template/     # this repo, only with ./apply.sh --admin
```

## Setting up for a team (once)

Fork this template, then edit and commit:

- `meta-repo.yaml`: `metarepo_id`, the `folders` (repos) everyone works on,
  `separate_mounts`, `persistent_volumes`, `ports` and the `env` keys the
  container needs.
- `.devcontainer/Dockerfile`: extra tools. Uncomment the certs block if you
  need corporate CA certificates (put `.crt` files in `.devcontainer/certs/`).
- `.root/AGENTS.md` and `.agents/skills/`: instructions and skills for agents.

## Using it (each person)

Requirements: Docker, VS Code with the Dev Containers extension, and
[mikefarah/yq](https://github.com/mikefarah/yq#install) v4 (`brew install yq`).

1. Clone your repos into one folder, e.g. `~/git-workspace/foo`, `~/git-workspace/bar`.
2. Create your local config:

   ```bash
   cp meta-repo.local.yaml.template meta-repo.local.yaml
   ```

   Set `root`, values for each `env` key, and any proxies. Optionally set `git`
   name and email if commits inside the container should be attributed to
   something other than your host `.gitconfig`.
3. Generate the Compose config:

   ```bash
   ./apply.sh           # or ./apply.sh --admin to also mount this repo
   ```

4. Open this folder in VS Code and run **Dev Containers: Reopen in Container**.

After changing `meta-repo.yaml`, `meta-repo.local.yaml` or the Dockerfile,
re-run `./apply.sh` and **Dev Containers: Rebuild Container**. Changes to
`.agents/` and `.root/` files show up live.

## Agent skills

Skills come from [dwjohnston/agent-skills](https://github.com/dwjohnston/agent-skills)
and are tracked in `skills-lock.json`:

```bash
make skills-add      # bunx skills add dwjohnston/agent-skills
make skills-update   # bunx skills update
```

## Configuration

| `meta-repo.yaml` (committed) | `meta-repo.local.yaml` (gitignored) |
|---|---|
| `metarepo_id`, `metarepo_suffix` | `root` (host path) |
| `folders`, `separate_mounts`, `ignore` | `env` values |
| `persistent_volumes`, `ports` | `proxy` |
| `env` keys | `dotfiles` |
| | extra personal `folders` |

The local file overrides the shared one. `folders` are combined, matched on
`path`. `git` (the commit identity) can go in either file; the local file wins,
so a team default in `meta-repo.yaml` is overridable per person. Each folder is mounted at `/workspace/<folder name>`, so folder names
must be unique.

### Hiding files (`ignore`)

List glob patterns under a folder's `ignore` to keep files such as secrets out
of the container:

```yaml
folders:
  - path: "foo"
    ignore:
      - .env*            # no `/`: matches the name at any depth
      - config/**/*.pem  # with `/`: matched from the folder root
      - secrets/         # trailing `/`: directories only
```

In the container a matched file appears empty and read-only, and a matched
directory appears empty. The host files are untouched. `.git` and
`separate_mounts` are never searched.

Patterns are expanded when `./apply.sh` runs, so a file created later is
**not** hidden until you re-run `./apply.sh` and rebuild. `apply.sh` lists
everything it hid.

### Environment variables and secrets

`env` values may reference host environment variables (`$VAR` / `${VAR}`).
`apply.sh` writes them unexpanded and Compose resolves them when the container
starts, so secrets aren't written to disk. They are read from the environment
of the process that starts the container. On macOS, VS Code launched from the
Dock may not see variables exported in your shell profile: launch it with
`code .` from a terminal. Use `$$` for a literal `$`.

### Dotfiles

List files or directories under your host home in `meta-repo.local.yaml` to
bring your aliases and shell setup into the container:

```yaml
dotfiles:
  - ~/git-workspace/dotfiles/aliases
  - ~/.my-functions
```

Each is bind-mounted **read-only** at the same path under `/home/vscode`.
Missing entries are skipped with a warning. Edits on the host show up live.

Every listed **file** is also sourced, in order, by the image's `~/.bashrc` and
`~/.zshrc` (via `META_REPO_DOTFILES`, set by `apply.sh`). Directories are
mounted but not sourced. Source the same files from your host `.zshrc` too.
Paths must not contain `:`. Don't mount a whole `.zshrc`/`.bashrc`: it would
replace the image's own (which sets up nvm) and usually contains macOS paths
and secrets. VS Code already copies your host `.gitconfig` into the container.
Don't list files containing secrets: everything mounted is readable in the
container. Changing the list needs `./apply.sh` and a container rebuild.

### Ports

`ports` lists container ports, or `start-end` ranges, to reach from the host.
Each is published on `127.0.0.1` at the same port + 10000:

```yaml
ports:
  - 3000-3003   # http://localhost:13000-13003
  - 5173        # http://localhost:15173
```

Servers must listen on `0.0.0.0` inside the container. Keep the list short:
publishing a large range makes the container very slow to start. Setting
`ports` in `meta-repo.local.yaml` replaces the shared list.

### Proxies

`proxy.buildtime` is used only while building the image (it is not kept in the
image). `proxy.runtime` becomes `HTTP_PROXY` / `HTTPS_PROXY` / `NO_PROXY` (and
lowercase) in the container. Either can be left empty. Neither is picked up
automatically from your host.

### Volumes

Volumes are named `<metarepo_id>-<metarepo_suffix>-…`, so different meta-repos
and different checkouts of the same one never share them:

- `separate_mounts`: `<project>-folder-<folder>-<mount>`, e.g. `node_modules`
  kept off the host.
- `persistent_volumes`: `<project>-persist-<name>`.
- Agent state: `<project>-claude` (`~/.claude`, including `.claude.json`),
  `<project>-dsh` (`~/.dsh`, including session and diagnostic logs),
  `<project>-copilot` (`~/.copilot`), `<project>-vscode-agent-sessions` and
  `<project>-vscode-global-storage` (under `~/.vscode-server/data`).

Here `<project>` is the Compose project name, `<metarepo_id>-<suffix>`. The
suffix is `metarepo_suffix` when you set it, and a hash of the checkout's path
when you don't — so a second clone or worktree gets its own volumes with no
configuration. The hash follows the path, so **moving the directory changes the
name** and leaves the old volumes behind; set `metarepo_suffix` to pin it if you
move.

To start completely fresh, remove the container and then the volumes:
`docker volume ls --filter name=<metarepo_id>-<suffix>-`.

## Host platforms

- **macOS**: supported.
- **Linux**: supported. The container user is remapped to your UID, and the
  entrypoint fixes volume ownership.
- **Windows**: WSL2 only, untested. Keep the repos and this repo inside the WSL2
  filesystem and run `./apply.sh` from WSL.

See [DECISIONS.md](DECISIONS.md) for the reasoning behind the design.


## Philosophy

This is a work in progress. 

Consider the ways such a template might want to be used:


1. As a general container for a single person for multiple repos, whether related or not
2. As a single repo container for some work, to be version controlled 
3. A shared project container for an entire team 
  - Needs .gitignored individual mappings for things like file paths, environment variables 

_This started out as 3. but I'm moving it back to 1+2._

Right now, I'm indexing on this _working for me_ and I'm not paying attention to the experience for teams.



## Credential sharing

Credential sharing is proving to be a bit of a bug bear. 

This thread is informative: 

https://github.com/microsoft/vscode-remote-release/issues/9466

The issue is that I would prefer the container _not_ to share my host git credentials - I don't want the agent going rogue with my full git permissions. 

I've got it working:

- provide GITHUB_TOKEN as an env var
- It is expected to work for _all_ repos. 




## Short comings 


- Ignore globs will be lost. 
