# Katello Project Context

Katello is a free open source plugin for Foreman focused on content management, including software packages, Puppet modules, and Docker containers.

## Project Overview
- **Technology Stack**: Ruby on Rails plugin for Foreman with React frontend components
- **Purpose**: Content lifecycle management - repository synchronization, content views, lifecycle environments
- **Architecture**: Plugin architecture extending Foreman with additional models, controllers, and UI components
- **Key Components**: Pulp (content management), Candlepin (subscription management), Elasticsearch (search)

## Repository Structure
- `app/` - Rails plugin components (controllers, models, views, helpers, jobs)
- `engines/` - Sub-engines for different functionality areas
- `webpack/` - Frontend JavaScript/React components
- `lib/` - Library code, tasks, and plugin initialization
- `test/` - Test suite including unit, functional, and integration tests
- `config/` - Plugin configuration and initializers
- `db/` - Database migrations specific to Katello

## Development Context
- Rails plugin extending Foreman's functionality
- Uses same tech stack as Foreman: Rails + React/AngularJS
- Integrates with external services (Pulp, Candlepin)
- Extensive API surface for content management operations
- Complex data modeling for content relationships

## Key Features
- Repository management and synchronization
- Content Views for content composition and versioning
- Lifecycle Environments for content promotion
- Subscription and entitlement management
- Errata and package management
- Container image management
- Ansible collection management

## Development Guidelines

### Contribution Standards
- Follow Foreman contribution standards
- Reference Redmine issue in commit message format: `Fixes #<issue> - <description>`
- Use feature branches and submit PRs from personal fork
- One commit per bug/feature when possible

### Testing Requirements
- Run targeted tests with `ktest` script for faster feedback
- Support for Ruby, JavaScript (AngularJS/React) testing
- Test individual files: `bundle exec rake test TEST=specific_test_file`
- Emphasizes selective testing over full suite runs for development

### Testing Commands
- `ktest` - Faster local testing script (recommended)
- `bundle exec rake test` - Full test suite
- `bundle exec rake test:katello` - Katello-specific tests
- JavaScript tests for frontend components

## Release Management
- Weekly triage meetings for issue prioritization
- Structured release process with release owner and packager roles
- Uses `tool_belt` for release configuration and tracking
- Component upgrade procedures for Pulp and Candlepin

## External Dependencies
- **Pulp**: Content repository management backend
- **Candlepin**: Subscription and entitlement management
- **Elasticsearch**: Search and indexing
- Requires understanding of these systems for full development context

## Common Development Areas
- Content synchronization and management
- Subscription and entitlement workflows
- Content View composition and promotion
- Repository and package management
- Integration with external content sources
- Performance optimization for large content sets

## Community & Support
- Issue tracker: Redmine (same as Foreman)
- Weekly triage meetings for community issue review
- Collaborative community-driven development
- GitHub-based workflow for contributions

## Security Considerations
- Handles sensitive subscription data
- Integration with external authentication systems
- Content verification and validation
- Secure communication with backend services