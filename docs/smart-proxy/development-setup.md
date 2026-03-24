---
title: Smart Proxy Development Setup
type: note
permalink: foreman/smart-proxy-development-setup
---

# Smart Proxy Development Setup

## Project Structure
- **Language**: Ruby
- **Framework**: Sinatra
- **Testing**: Test::Unit framework
- **Packaging**: Gemspec-based gem

## Key Files
- `smart_proxy.gemspec`: Gem specification
- `Gemfile`: Dependency management
- `config.ru`: Rack application entry point
- `lib/smart_proxy_main.rb`: Main application entry
- `lib/launcher.rb`: Application launcher

## Development Commands
- Bundle installation: `bundle install`
- Testing: `rake test` (likely, based on Rakefile presence)
- Server start: `bundle exec rackup` or custom scripts in `bin/`

## Testing Structure
- Test files in `test/` directory
- Integration tests for each plugin
- Unit tests for core functionality
- Test fixtures in `test/fixtures/`
- Benchmark tests for performance-critical code

## Configuration
- Development settings in `bundler.d/development.rb`
- Test settings in `bundler.d/test.rb`
- SSL test certificates in `test/fixtures/ssl/`

## Build System
- Rake tasks in `tasks/` directory
- Jenkins integration (`tasks/jenkins.rake`)
- Packaging tasks (`tasks/pkg.rake`)
- Code quality with RuboCop (`tasks/rubocop.rake`)

## Logging
- Log configuration in `config/settings.d/logs.yml.example`
- Test logs in `logs/test.log`
- Structured logging with configurable levels

## SSL/Security
- SSL certificate management
- Client certificate verification
- Trusted hosts configuration
- HSTS middleware support (recent addition)