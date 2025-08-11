# Puppet IOP Module Context

This is a Puppet module for configuring IoP (Insights-on-Prem) services, part of the Foreman ecosystem.

## Module Overview
- **Name**: theforeman-iop
- **Purpose**: Module for configuring IOP services
- **Repository**: https://github.com/theforeman/puppet-iop
- **License**: GPL-3.0+

## Architecture
IoP provides on-premises Red Hat Insights functionality with the following core services:
- **Core Services**: ingress, puptoo, yuptoo, engine, gateway, host_inventory, kafka
- **Vulnerability Services**: vmaas, vulnerability, vulnerability_frontend, metadata_downloader
- **Advisor Services**: advisor, advisor_frontend, remediations

## Key Technologies
- **Puppet**: Configuration management (version >= 8.0.0)
- **Podman**: Container orchestration (southalc/podman module)
- **Certificates**: SSL/TLS handling (katello/certs module)
- **Database**: PostgreSQL with Foreign Data Wrapper support
- **Message Queue**: Kafka for event streaming

## Development Standards
- Follows Puppet module conventions
- Uses EPP templates for configuration files
- Supports RHEL 9, CentOS 9, AlmaLinux 9
- Includes comprehensive acceptance tests using rspec-puppet

## Testing
- Acceptance tests in `spec/acceptance/`
- Unit tests in `spec/classes/`
- Test framework: rspec-puppet with beaker for acceptance testing

## Dependencies
- puppetlabs/stdlib (>= 9.0.0)
- puppet/extlib (>= 3.0.0)
- southalc/podman (>= 0.7.5)
- katello/certs (>= 20.0.0)

## File Structure
- `manifests/`: Puppet class definitions
- `templates/`: EPP template files
- `files/`: Static configuration files
- `lib/`: Custom Puppet types and providers
- `spec/`: Test specifications