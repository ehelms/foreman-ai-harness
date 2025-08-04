# Hammer CLI Context

Hammer CLI is the command-line interface for Foreman and its plugins.

## Project Information
- Repository: hammer-cli
- Language: Ruby
- Purpose: CLI tool for managing Foreman resources
- Testing: Uses RSpec for testing

## Key Conventions
- Follow Ruby style guidelines
- Use existing CLI command patterns
- Commands are organized by resource type
- Options follow standard CLI conventions with --long-form and -s short forms

## Common Tasks
- Adding new commands: Extend from HammerCLI::AbstractCommand
- Adding options: Use option method with appropriate parsers
- Testing: Write RSpec tests in test/ directory
- Building: Use standard Ruby gem building process

## Dependencies
- Check Gemfile for current dependencies
- Common gems: clamp (command framework), rest-client, oauth