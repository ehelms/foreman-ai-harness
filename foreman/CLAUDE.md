# Foreman Project Context

Foreman is a free open source project that automates infrastructure management, provisioning, and orchestration.

## Project Overview
- **Technology Stack**: Ruby on Rails application with React frontend components
- **Purpose**: Infrastructure lifecycle management - provisioning, configuration, orchestration, monitoring
- **Architecture**: Web-based with RESTful API, CLI, and Smart Proxy architecture
- **Integrations**: Puppet, Ansible, Chef, Salt via smart proxy

## Repository Structure
- `app/` - Main Rails application (controllers, models, views, helpers, jobs)
- `config/` - Rails configuration, initializers, routes
- `db/` - Database migrations and seeds
- `test/` - Test suite
- `webpack/` - Frontend JavaScript/React components
- `lib/` - Library code and Rake tasks
- `script/` - Development and utility scripts

## Development Context
- Rails application following MVC pattern
- Uses Apipie for API documentation
- Webpack for frontend asset compilation
- Rubocop for code linting
- Comprehensive test suite with Jenkins CI

## Key Features
- Host provisioning and management
- Template-based configuration
- Multi-tenancy with Organizations and Locations
- Plugin architecture for extensibility
- RBAC authorization system
- Audit logging

## Development Guidelines

### Contribution Standards
- One commit per bug/feature
- Reference Redmine issue in commit message
- Commit message format: `Fixes #<issue> - <description>`
- Create feature/topic branch for changes
- Submit pull requests from personal fork

### Testing Requirements
- Run full test suite: `bundle exec bin/rake test`
- Run single test: `bundle exec bin/rake test TEST=specific_test_file`
- All tests must pass before submitting PR

### Development Environment
- Requires: Linux, Ruby, Ruby on Rails, JavaScript, React
- Two setup options: preconfigured VM (recommended) or manual git setup
- Check Foreman handbook for detailed code guidelines

## Common Commands
- `rake rubocop` - Run code linting
- `bundle exec bin/rake test` - Run test suite
- Development setup scripts in `script/` directory

## Community & Support
- Issue tracker: Redmine
- Communication: Forum or Matrix channels
- Contribution areas: code, user support, bug reports, translations, documentation

## Licensing & Security
- GPL v3 licensed with some exceptions
- Includes authentication and authorization systems
- Smart proxy for secure remote operations