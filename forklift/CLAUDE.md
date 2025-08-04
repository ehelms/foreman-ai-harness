# Forklift Project Context

Forklift provides tools to create Foreman/Katello environments for development, testing and production configurations.

## Project Overview
- Ansible-based deployment tool for Foreman/Katello
- Supports development, testing, and production deployments
- Uses Vagrant with libvirt/VirtualBox for local environments
- Supports CentOS Stream, Debian, and other operating systems
- Includes testing infrastructure with Bats tests and pipeline testing

## Common Commands
- `vagrant status` - List available boxes
- `vagrant up <box-name>` - Start specific environment
- `vagrant ssh <box-name>` - SSH into environment
- `ansible-playbook playbooks/<playbook>.yml` - Run deployment playbooks
- `bats bats/<test-file>.bats` - Run Bats tests

## Key Directories
- `playbooks/` - Ansible playbooks for different deployment types
- `inventories/` - Inventory files for different environments  
- `roles/` - Ansible roles
- `vagrant/` - Vagrant configuration files
- `vagrant/boxes.d/` - Box configuration files
- `bats/` - Bats test suite
- `pipelines/` - Pipeline testing configurations
- `docs/` - Documentation

## Development Environment Setup
1. Copy `vagrant/boxes.d/99-local.yaml.example` to `vagrant/boxes.d/99-local.yaml`
2. Configure GitHub username and other variables
3. Run `vagrant up centos9-katello-devel` for development environment
4. Access via `vagrant ssh` and start with `bundle exec foreman start`

## Testing
- Bats tests available for various components (content, client, proxy, etc.)
- Pipeline testing for install/upgrade scenarios
- Robottelo integration for comprehensive testing
- CI system uses `centos9-katello-bats-ci`

## Production Deployment
- BYOB (Bring Your Own Box) support for bare metal/existing VMs
- Remote deployment via Ansible inventory
- Local deployment option
- Version compatibility defined in `config/versions.yaml`

## Development Practices
- Follow existing Ansible best practices
- Test in development environment before production
- Use existing role and playbook patterns
- Follow YAML formatting conventions
- Check documentation in docs/ for specific workflows