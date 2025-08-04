# Foreman Remote Execution Plugin Context

This is the Foreman Remote Execution plugin - a Ruby on Rails plugin that brings remote execution capabilities to Foreman.

## Project Structure
- **Language**: Ruby (Rails plugin/gem)
- **Framework**: Ruby on Rails plugin for Foreman
- **Frontend**: Mix of ERB templates and React components (webpack)
- **Dependencies**: dynflow, foreman-tasks, deface

## Key Components
- **Models**: Job templates, job invocations, targeting, template invocations
- **Controllers**: API v2 controllers, job invocations, job templates
- **Views**: ERB templates + React components for job wizards and details
- **Actions**: Dynflow actions for remote execution (run_host_job, run_hosts_job)
- **Providers**: Script execution provider for SSH-based execution

## Testing
- Uses standard Rails testing with factories
- Run tests with: `bundle exec rake test:foreman_remote_execution`
- Rubocop: `bundle exec rake foreman_remote_execution:rubocop`

## Development Notes
- Job templates stored in `app/views/templates/script/`
- React components in `webpack/` directory
- Database migrations in `db/migrate/`
- Supports simulation mode via REX_SIMULATE env vars
- Templates synced from community-templates repo

## Common Tasks
- Template development: Edit files in `app/views/templates/script/`
- React components: Work in `webpack/` directory
- API changes: Controllers in `app/controllers/api/v2/`
- Model changes: Files in `app/models/`
- Database changes: Add migrations to `db/migrate/`