# How agent harnesses discover skills and instructions

Researched 28 October 2026. This answers one question: if an agent session is pointed at one repo inside `/workspace`, which skills and instruction files does it load?

It informs the layout in [workspace-layout.md](../plan/workspace-layout.md).

## Finding

**Starting a session inside a repo scopes that repo's skills correctly in every harness. Only Claude Code also reads files above the repo.** Copilot CLI, Codex and VS Code's built-in chat stop at the git root, so `/workspace/AGENTS.md` and `/workspace/.agents/skills` are invisible from inside `/workspace/blog`. Content meant for every session needs to go in user-level locations too.

## Comparison

| Harness | Starts from | Reads directories above that? | Picks up skills in subfolders? | User-level location |
|---|---|---|---|---|
| **Claude Code** ([memory][cc-memory], [skills][cc-skills]) | The directory it was started in | Yes, all the way up to `/` | Yes, the first time it reads or edits a file in that subfolder | `~/.claude/CLAUDE.md`, `~/.claude/skills` |
| **Copilot CLI** ([docs][copilot-cli]) | Every directory from the git root down to where it was started | Only up to the git root | When working on a file there (inferred from the wording) | `~/.copilot/` |
| **Codex** ([AGENTS.md][codex-agents]) | Every directory from the git root down to where it was started | Only down from the git root | No | `~/.codex/AGENTS.md`, `~/.agents/skills` |
| **VS Code built-in Copilot chat** ([instructions][vsc-instructions], [skills][vsc-skills]) | The root of each folder open in the window | Only with `chat.useCustomizationsInParentRepositories` turned on, and then only up to `.git` | Subfolder `AGENTS.md` only with `chat.useNestedAgentsMdFiles` | `~/.copilot/skills`, `~/.claude/skills`, `~/.agents/skills` |
| **[agentskills.io][agentskills] spec** | Not specified; each tool decides where to look | | | |

Key quotes:

- Claude Code: "Claude Code loads `CLAUDE.md` … from your current working directory and every directory above it." Subdirectory files load "once Claude reads, writes, or edits another file in that subdirectory."
- Copilot CLI: instructions come from "the repository root, the current working directory, intermediate directories between them, and any directories nested in the path of a file it is working on."
- Codex: "If Codex cannot find a project root, it only checks the current directory."

In VS Code, the `chat.*` settings only affect the built-in Copilot chat. When the chat runs Claude, Codex or Copilot CLI, each of those uses its own rules from the table above ([harnesses][vsc-harnesses]). VS Code also discourages custom skill locations because "GitHub Copilot CLI and the GitHub Copilot app do not inherit editor settings."

## Ways to point a session at one repo

- **Agents window:** choose *Select Folder or Repository* when you start a session, optionally with a git worktree ([docs][vsc-agents-window]). It's experimental and still has bugs, for example [#316243][vsc-316243], where Copilot CLI sessions start in the terminal's directory instead.
- **CLI:** `cd /workspace/blog && claude`, `copilot` or `codex`.
- **Status bar indicator:** [Project Manager][project-manager] shows the current project, but it switches the whole window rather than a single agent session. [Workspace Sidebar][workspace-sidebar] is similar.
- **Skills:** none found whose purpose is "cd into this repo".

## Feature requests worth following

| Issue | Topic |
|---|---|
| [vscode#307630](https://github.com/microsoft/vscode/issues/307630) | Limit which skills an agent sees |
| [vscode#324646](https://github.com/microsoft/vscode/issues/324646) | Find skills in nested folders |
| [vscode#340867](https://github.com/microsoft/vscode/issues/340867) | Copilot picks the wrong folder in a workspace with several open |
| [vscode#255196](https://github.com/microsoft/vscode/issues/255196) | Instructions per folder in multi-root workspaces |
| [vscode#343749](https://github.com/microsoft/vscode/issues/343749) | Agent-host chats ignore `chat.agentSkillsLocations` |
| [codex#57106](https://github.com/openai/codex/issues/57106) | Choose the working directory when starting a thread |
| [codex#44863](https://github.com/openai/codex/issues/44863) | Choose the directory per conversation from the active file |
| [claude-code#102311](https://github.com/anthropics/claude-code/issues/102311) | Multi-repo sessions load every repo's `CLAUDE.md` |

## Limits of this research

- Not verified: how the Claude Code VS Code extension picks its starting directory.
- Not searched: the `microsoft/vscode-copilot-release` issue tracker.
- Nothing was tested in a container. Confirm the user-level mount approach in a scratch container before building on it.

[cc-memory]: https://code.claude.com/docs/en/memory
[cc-skills]: https://code.claude.com/docs/en/skills
[copilot-cli]: https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions
[codex-agents]: https://learn.chatgpt.com/docs/agent-configuration/agents-md
[vsc-instructions]: https://code.visualstudio.com/docs/agent-customization/custom-instructions
[vsc-skills]: https://code.visualstudio.com/docs/agent-customization/agent-skills
[vsc-harnesses]: https://code.visualstudio.com/docs/agents/run/agent-harnesses
[vsc-agents-window]: https://code.visualstudio.com/docs/agents/run/agents-window
[vsc-316243]: https://github.com/microsoft/vscode/issues/316243
[agentskills]: https://agentskills.io/specification.md
[project-manager]: https://marketplace.visualstudio.com/items?itemName=alefragnani.project-manager
[workspace-sidebar]: https://marketplace.visualstudio.com/items?itemName=sketchbuch.vsc-workspace-sidebar
