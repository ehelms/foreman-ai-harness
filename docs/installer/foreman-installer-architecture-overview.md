---
title: Foreman-Installer Architecture Overview
type: note
permalink: installer/foreman-installer-architecture-overview
---

# Foreman-Installer Architecture Overview

## Core Design Philosophy

The foreman-installer is built on the **Kafo framework** (https://github.com/theforeman/kafo), which transforms Puppet modules into user-friendly installers. It provides a comprehensive, flexible, and repeatable installation process for the entire Foreman ecosystem through a modular, configuration-driven approach.

### Foundation: Kafo Framework
- **Ruby Gem**: Kafo serves as the underlying installer framework
- **Puppet Module Integration**: Automatically discovers and exposes Puppet module parameters
- **Dynamic Interface Generation**: Creates CLI and interactive interfaces from Puppet manifests
- **Scenario-Based Architecture**: Supports multiple installation profiles and configurations

## Key Architectural Principles

### 1. Modular Design
- **Component-based**: Each major service (Foreman, Smart Proxy, Puppet server) is handled by separate modules
- **Plugin System**: Supports enabling/disabling various plugins and compute resources
- **Granular Control**: Allows fine-tuned configuration of individual components

### 2. Configuration-Driven Installation (via Kafo)
- **Answer Files**: Uses YAML-based configuration in `/etc/foreman-installer/scenarios.d/foreman-answers.yaml`
- **CLI Parameters**: Auto-generated command-line arguments from Puppet module parameters
- **Interactive Mode**: Kafo-powered guided configuration with parameter discovery
- **Persistent Configuration**: Generates and maintains configuration state across installations
- **Parameter Discovery**: Automatic extraction of configuration options from Puppet manifests

### 3. Multi-Scenario Support
- **All-in-one**: Complete Foreman stack on single host
- **Standalone Foreman**: Web UI only
- **Distributed**: Foreman with separate Smart Proxy installations
- **Puppet Integration**: Puppetmaster with Git and Proxy configurations

## Installation Approaches

### Package-Based (Recommended)
- Native OS packaging (RPM/DEB)
- Stable releases through official repositories
- Integrated with OS package management

### Git-Based (Development)
- Clone with submodules: `git clone --recursive`
- Development branch access
- Source-based installation and testing

## Repository Structure

### Core Directories
- **`bin/`**: Executable scripts and entry points
- **`config/`**: Configuration templates and scenarios
- **`hooks/`**: Installation hooks and callbacks
- **`checks/`**: Pre-installation validation scripts
- **`spec/`**: Test specifications
- **`util/`**: Utility scripts and helpers
- **`katello_certs/`**: Certificate management for Katello integration

## Supported Components

### Core Services
- **Foreman Web UI**: Main application interface
- **Smart Proxy**: Remote service management
- **Puppet Server**: Configuration management backend

### Optional Services
- **DHCP**: Network boot support
- **DNS**: Domain name services
- **TFTP**: Network boot file serving
- **Katello**: Content management (separate installer scenario)

## Technical Implementation

### Language and Tooling
- **Core Framework**: Kafo Ruby gem for installer functionality
- **Primary Language**: Ruby (92.9% of codebase)
- **Configuration Management**: Puppet-based module system with Kafo orchestration
- **Interface Generation**: Dynamic CLI and interactive modes via Kafo
- **Package Management**: Native OS integration
- **Testing**: RSpec-based test suite

### Cross-Platform Support
- Multiple Linux distributions
- Consistent installation experience across platforms
- OS-specific package management integration

## Design Benefits

1. **Flexibility**: Supports complex multi-host configurations
2. **Repeatability**: Consistent deployments across environments
3. **Maintainability**: Modular structure enables focused development
4. **Scalability**: Distributed deployment capabilities
5. **Extensibility**: Plugin and module system for customization

## References

- **Kafo Framework**: https://github.com/theforeman/kafo
- **Foreman-Installer Repository**: https://github.com/theforeman/foreman-installer
- **Foreman Installation Guide**: https://docs.theforeman.org/nightly/Installing_Server/index-foreman-el.html
- **Katello Installation**: https://github.com/theforeman/foreman-installer/blob/develop/KATELLO.md