# Foreman AI Harness

A [lola](https://github.com/LobsterTrap/lola) module for the Foreman community. This repository curates the resources needed to effectively use AI coding agents across the Foreman ecosystem.

## What This Module Provides

- **Skills** - Reusable AI agent skills tailored to Foreman development workflows
- **Agents** - Specialized agent configurations for Foreman projects
- **Development Documentation** - References for common development patterns, commands, and workflows across Foreman projects
- **Architecture and Design Documentation** - Architectural analysis and design documents for Foreman core, Katello, Smart Proxy, the installer, and related components

## Installation

### Using Lola

Install [lola](https://lobstertrap.org/lola/) first, then add and install this module:

```bash
# Add the module to your lola registry
lola mod add https://github.com/theforeman/foreman-ai-harness.git

# Install to your AI assistant (e.g. Claude Code)
lola install foreman-dev-skills -a claude-code
```

See [Installation Scope](#installation-scope) below for choosing between project and user scope.

### From a Local Clone

```bash
git clone https://github.com/theforeman/foreman-ai-harness.git
cd foreman-ai-harness
lola mod add ./foreman-dev-skills
lola install foreman-dev-skills -a claude-code
```

### Declarative Installation

Add this module to a `.lola-req` file in any project to install it automatically with `lola sync`:

```
https://github.com/theforeman/foreman-ai-harness.git
```

Then run:

```bash
lola sync
```

Use `lola sync --dry-run` to preview what would be installed.

## Installation Scope

Lola supports two installation scopes that control where skills are available:

### Project Scope (default)

```bash
lola install foreman-dev-skills -a claude-code
```

Skills are installed into the current project directory (e.g. `.claude/skills/`). Use project scope when:

- You only need the skills in a specific repository
- You want skills versioned alongside the project (the installed files appear in the project tree)
- Different projects need different skill versions

### User Scope

```bash
lola install foreman-dev-skills -a claude-code --scope user
```

Skills are installed to your user-level assistant configuration (e.g. `~/.claude/skills/`). Use user scope when:

- You want the skills available across all your projects without installing per-repo
- You work on many Foreman repositories and want a single shared set of skills
- You don't want skill files showing up in project directories

### Switching Scope

To move an installation from one scope to another, uninstall from the old scope and reinstall to the new one:

```bash
lola uninstall foreman-dev-skills --scope project
lola install foreman-dev-skills -a claude-code --scope user
```

## Updating

When new skills or updates are released in this repository, update your local copy:

```bash
# Re-fetch the module source from git
lola mod update foreman-dev-skills

# Regenerate the installed assistant files from the updated source
lola update foreman-dev-skills
```

`lola mod update` pulls the latest changes from the git repository into your local lola registry (`.lola/modules/`). `lola update` then regenerates the assistant-specific files (e.g. `.claude/skills/`) from that updated source.

To update all modules at once:

```bash
lola mod update
lola update
```

If you pinned a specific version with `--ref` when adding, the update will pull that ref. To track a different branch or tag:

```bash
lola mod rm foreman-dev-skills
lola mod add https://github.com/theforeman/foreman-ai-harness.git --ref v2.0
lola install foreman-dev-skills -a claude-code
```

## Contributing

Contributions are welcome for:

- Adding or improving skills for Foreman development workflows
- Adding specialized agent definitions
- Expanding architecture and design documentation
- Adding development references for Foreman ecosystem projects
- Improving agent instructions in `foreman-dev-skills/AGENTS.md`

See [DEVELOPMENT.md](DEVELOPMENT.md) for the full development guide, including how to create skills, test locally, and submit changes.

