# Foreman RH Cloud Plugin Context

Foreman plugin that connects Foreman instances to the Red Hat Hybrid Cloud Console.

## Project Overview
- **Technology Stack**: Rails engine with React frontend components
- **Purpose**: Bridge between Foreman and Red Hat Hybrid Cloud Console services
- **Architecture**: Plugin extends Foreman with cloud integration capabilities
- **Authentication**: Uses Katello client certificates and mTLS

## Core Functionality
- **Inventory reports** - Generate and upload host inventory to Red Hat cloud
- **Recommendations and remediations** - Sync security/compliance recommendations from cloud
- **Cloud connector** - Enable cloud-initiated remediations via rhcd service
- **Client tools forwarding** - Proxy insights-client requests through Foreman

## Repository Structure
- `app/` - Standard Rails structure (models, controllers, views)
- `lib/` - Non-Rails specific code, organized by namespace
- `webpack/` - React components following consistent structure
- `test/` - Test suite with fixtures and helpers

## Key Namespaces
- **ForemanInventoryUpload** - Inventory report generation and upload
- **InsightsCloud** - Recommendations sync and remediation handling
- **InventorySync** - Host status synchronization with cloud
- **ForemanRhCloud** - Core plugin services and utilities

## Development Context
- Rails engine plugin architecture
- React components with Redux for state management
- Background jobs for async operations
- Comprehensive test coverage with JavaScript and Ruby tests

## Development Guidelines

### Testing Requirements
- `npm test` - Run JavaScript tests
- `npm run test:watch` - Run tests in watch mode
- `npm run test:current` - Run tests for current changes
- `rake test` - Run Ruby tests
- `rake` - Run default task (includes tests and rubocop)

### Code Quality
- `npm run lint` - Run JavaScript linting with tfm-lint
- `npm run lint:spelling` - Run spelling checks on JavaScript
- `rake rubocop` - Run Ruby style/lint checks

## Important Rake Tasks
- `rh_cloud_inventory:report:generate_upload` - Generate and upload inventory reports
- `rh_cloud_inventory:sync` - Sync inventory status with cloud
- `rh_cloud_insights:sync` - Sync recommendations from cloud

## External Dependencies
- **Red Hat Cloud APIs** - Multiple endpoints for inventory, insights, remediations
- **Foreman REX** - Remote execution for running remediation playbooks
- **rhcd service** - Cloud connector daemon for cloud-initiated actions
- **yggdrasil-worker-forwarder** - Worker for cloud connector communication

## Security Features
- mTLS authentication with organization manifests
- Proper proxy settings for cloud communications
- Authenticated forwarders for all cloud requests
- Certificate-based host authentication via Katello