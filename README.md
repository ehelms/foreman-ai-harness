# Foreman Ecosystem Claude Context

This repository provides Claude Code context for the Foreman ecosystem, including Foreman core, Katello, and related projects.

## Setup

1. Clone this repository to your Claude context directory:
   ```bash
   git clone https://github.com/ehelms/foreman-context.git ~/.claude/theforeman
   ```

2. Add the import to your main `~/.claude/CLAUDE.md` file:
   ```markdown
   @~/.claude/theforeman/CLAUDE.md
   ```

## Structure

- `CLAUDE.md` - Main context file that imports project-specific contexts
- `foreman/CLAUDE.md` - Foreman core project context
- `katello/CLAUDE.md` - Katello project context

## Usage

Once set up, Claude Code will automatically load the relevant context when working in Foreman-related repositories. The context includes project-specific conventions, common patterns, and helpful reminders for working with the Foreman ecosystem.

### Memory System

This project uses Basic Memory, an MCP (Model Context Protocol) server, to maintain knowledge and context across sessions. Learn more about Basic Memory at https://docs.basicmemory.com/getting-started/

Basic Memory is compatible with any tool that supports MCP integration, not just Claude Code. The memory system helps AI assistants:
- Remember project architecture and design patterns
- Maintain context about foreman-installer and Kafo framework
- Store installation scenarios and configuration examples
- Build knowledge incrementally across development sessions

Since Basic Memory implements the MCP standard, it can be used with various AI tools and development environments that support the Model Context Protocol.

## Adding New Projects

To add context for additional Foreman ecosystem projects:

1. Create a new directory for the project
2. Add a `CLAUDE.md` file with project-specific context
3. Import it in the main `CLAUDE.md` file using `@~/.claude/theforeman/project-name/CLAUDE.md`