# Foreman AI Harness

An AI harness for the Foreman community. This repository curates the resources needed to effectively use AI coding agents across the Foreman ecosystem.

## What This Repository Provides

- **Skills** - Reusable AI agent skills tailored to Foreman development workflows
- **Agents** - Agent configurations and instructions for AI coding tools (Claude Code, Copilot, Cursor, Codex, etc.)
- **Development Documentation** - References for common development patterns, commands, and workflows across Foreman projects
- **Architecture and Design Documentation** - Architectural analysis and design documents for Foreman core, Katello, Smart Proxy, the installer, and related components

## Structure

- `AGENTS.md` - Shared AI agent instructions for all compatible tools
- `CLAUDE.md` - Claude Code-specific instructions
- `skills/` - Curated AI agent skills
- `docs/` - Documentation organized by component:
  - `docs/foreman/` - Foreman core documentation
  - `docs/installer/` - Installer and Kafo framework documentation
  - `docs/katello/` - Katello content management documentation
  - `docs/smart-proxy/` - Smart Proxy architecture documentation
  - `docs/iop/` - Insights-on-Prem documentation

## Installing Skills

Skills from this repository can be installed into your local AI coding environment using either of the methods below.

> **Note:** Skills are currently being curated. Check the `skills/` directory for available skills.

### Using Lola

[Lola](https://github.com/RedHatProductSecurity/lola) is a skill and prompt management tool for Claude Code.

Install a skill from this repository:

```bash
lola install github:ehelms/foreman-ai-harness/skills/<skill-name>.md
```

Update all installed skills:

```bash
lola update
```

See the [Lola documentation](https://github.com/RedHatProductSecurity/lola) for more details on managing skills.

### Using Vercel Skills

[Vercel Skills](https://github.com/vercel-labs/skills) provides a CLI for installing and managing Claude Code skills.

Install a skill from this repository:

```bash
npx @anthropic-ai/skills install github:ehelms/foreman-ai-harness/skills/<skill-name>.md
```

Update all installed skills:

```bash
npx @anthropic-ai/skills update
```

See the [Vercel Skills documentation](https://github.com/vercel-labs/skills) for more details.

## Contributing

Contributions are welcome for:

- Adding or improving skills for Foreman development workflows
- Expanding architecture and design documentation
- Adding development references for Foreman ecosystem projects
- Improving agent instructions in `AGENTS.md`
