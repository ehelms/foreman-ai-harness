# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository. For AI coding agent instructions that apply across multiple tools (e.g. Copilot, Cursor, Codex), see [AGENTS.md](AGENTS.md).

## Memory System Integration

This repository integrates with Basic Memory (MCP server) for maintaining development context across sessions. The system stores:
- Project architecture and design patterns
- Installation scenarios and configuration examples
- Cross-component integration patterns
- Development workflow knowledge

Access memory context using `memory://` URIs for related topics and previous discussions.
