---
title: foremanctl-container-installer
type: note
permalink: installer/foremanctl-container-installer
---

# Foremanctl Container-Based Installer

## Project Overview

**Repository**: https://github.com/theforeman/foremanctl
**RFC Discussion**: https://community.theforeman.org/t/rfc-foreman-production-installation-via-containers-and-podman-quadlets/40611

Foremanctl represents a new experimental approach to Foreman and Katello deployment using containers and modern container orchestration technologies.

## Design Philosophy

### Core Concept
"Testing a deployment of Foreman and Katello using Podman quadlets and Ansible"

### Fundamental Shift
- **From**: Traditional package-based installation with hundreds of OS-specific packages
- **To**: Container-based deployment with "build once, deploy many" approach

## Architecture Components

### Container Technology Stack
- **Container Runtime**: Podman
- **Service Framework**: Podman Quadlets (systemd integration)
- **Configuration Management**: Ansible
- **Secret Management**: Podman secrets with structured naming

### Technology Implementation
- **Primary Languages**: 
  - Python (40.3%) - Core logic and tooling
  - Jinja (36.4%) - Template generation
  - Shell (22.1%) - Automation scripts
  - Makefile (1.2%) - Build automation

## Key Design Principles

### 1. Container-Native Deployment
- **Build Artifacts**: Containers instead of native packages
- **OS Agnostic**: Reduced dependency on specific operating system packages
- **Consistency**: Same container images across all environments

### 2. Modern Container Orchestration
- **Podman Quadlets**: Systemd-integrated container management
- **Service Definition**: Declarative service configuration
- **Process Management**: Systemd handles container lifecycle

### 3. Configuration Management
- **Ansible Integration**: Declarative configuration and deployment
- **Secret Management**: Structured approach to sensitive data
- **Modular Services**: Each service can be configured independently

## Secret Management System

### Naming Conventions
```bash
# Configuration files
<role_namespace>-<filename>-<extension>

# String values
<role_namespace>-<descriptive_name>
```

### Examples
```bash
# Config file secrets
foreman-database-yml
katello-candlepin-conf

# String secrets
foreman-db-password
katello-admin-token
```

## Development Workflow

### Environment Setup
```bash
# 1. Initialize development environment
./setup-environment

# 2. Start virtual machines
./forge vms start

# 3. Deploy Foreman/Katello
./foremanctl deploy

# 4. Run validation tests
./forge test
```

### Development Tools
- **Vagrant Integration**: Automated VM provisioning for testing
- **Testing Framework**: Automated validation of deployments
- **Development Scripts**: Streamlined development workflow

## Deployment Architecture

### Container Services
- **Foreman Web Application**: Main UI and API
- **Katello Services**: Content management components
- **Database**: PostgreSQL container
- **Web Server**: Nginx/Apache proxy container
- **Smart Proxy**: Remote service management

### Service Orchestration
- **Quadlet Files**: Systemd service definitions for containers
- **Dependency Management**: Service startup ordering and dependencies
- **Health Checks**: Service monitoring and restart policies

## Problems Addressed

### Traditional Installer Challenges
1. **Package Complexity**: Hundreds of native packages per OS
2. **Runtime Dependencies**: Multiple language runtimes (Ruby, Python, Java)
3. **Upgrade Issues**: Package conflicts and lingering dependencies
4. **OS Fragmentation**: Different package sets for each supported OS

### Container Solutions
1. **Simplified Packaging**: Single container image per service
2. **Runtime Isolation**: Contained dependencies and runtimes
3. **Clean Upgrades**: Replace containers instead of in-place upgrades
4. **OS Independence**: Same containers across different operating systems

## Strategic Goals

### Immediate Objectives
- **Proof of Concept**: Validate container-based deployment approach
- **Performance Evaluation**: Compare container vs. native performance
- **Operational Assessment**: Evaluate day-to-day operational differences

### Long-Term Vision
- **Kubernetes Path**: Enable future Kubernetes deployment options
- **Simplified Development**: Easier development environment setup
- **Reduced Maintenance**: Lower packaging and testing overhead
- **Improved Scalability**: Container-native scaling patterns

## Implementation Status

### Current State
- **Experimental**: Active research and prototyping phase
- **CLI Approach**: Command-line interface using Ansible backend
- **Parameter Documentation**: Defining configuration options and constraints
- **Container Strategy**: Establishing image build and versioning processes

### Development Areas
- **Installation Workflow**: Streamlined deployment procedures
- **Upgrade Mechanisms**: Container-based upgrade strategies
- **Smart Proxy Integration**: Remote service deployment patterns
- **Migration Tools**: Path from traditional to container-based installations

## Technical Considerations

### Container Image Strategy
- **Base Images**: Initially built from RPM packages
- **Versioning**: Coordinated versioning across service containers
- **Registry**: Container image distribution and storage
- **Security**: Image scanning and vulnerability management

### Service Integration
- **Network Configuration**: Container networking and service discovery
- **Data Persistence**: Volume management for stateful services
- **Certificate Management**: SSL/TLS in containerized environment
- **Backup/Restore**: Data protection in container architecture

## Future Directions

### Research Areas
- **Performance Benchmarking**: Container vs. native performance analysis
- **Operational Patterns**: Best practices for container-based Foreman
- **Migration Strategies**: Transition paths from existing installations
- **Kubernetes Integration**: Future orchestration platform support
## Development Challenges and Issues

### Active Development Concerns
Based on GitHub issue analysis, several key areas require attention:

#### Security and Cryptography
- **Post-Quantum Cryptography**: Future-proofing against quantum threats
- **Crypto Policy Compliance**: Enterprise crypto policy management
- **Database Security**: SCRAM-SHA-256 authentication for PostgreSQL
- **Certificate Lifecycle**: Automated SSL/TLS certificate management

#### Testing and Quality Assurance
- **Molecule Testing**: Comprehensive Ansible testing framework integration
- **Testing Tool Evaluation**: Assessment of 'tmt' and other testing tools
- **CI/CD Pipeline**: Container-specific testing and validation workflows

#### Operational Challenges
- **Service Restart Management**: Graceful service lifecycle in containers
- **Debug and Logging**: Structured logging and diagnostic capabilities
- **Secret Rotation**: Dynamic secret updates in Podman environments
- **Recurring Tasks**: Container-native scheduling for maintenance operations

#### Database and Persistence
- **PostgreSQL Upgrades**: Database lifecycle management in containers
- **Connection Pooling**: PgBouncer integration for performance
- **Data Migration**: Strategies for container-based data transitions

## Container Infrastructure Gaps

### Missing OCI Repository Infrastructure
Current analysis reveals no dedicated container build repositories in the Foreman organization:

#### Official Container Infrastructure
- **Registry Strategy**: `quay.io/foreman/$service:$tag` (documented)
- **Dedicated Repositories**: foreman-oci-images, pulp-oci-images, candlepin-oci-images
- **Base Image**: `quay.io/centos/centos:stream9`
- **Container Variants**: Vanilla Foreman, Foreman+Katello, Foreman+All Plugins

#### Image Architecture Needs
```
Service Container Requirements:
├── foreman-web (Rails application + web server)
├── foreman-worker (background job processing)
├── postgresql (database with Foreman schema)
├── foreman-proxy (Smart Proxy services)
├── katello-web (content management UI)
├── pulp (content repository management)
└── candlepin (subscription management)
```

## Historical Context

### Evolution from Docker Plugin
The foremanctl approach represents a strategic shift from the discontinued foreman-docker plugin:

#### Previous Approach (Docker Plugin - Archived)
- **Scope**: Container management as Foreman feature
- **Architecture**: Plugin-based extension
- **Target**: Individual container lifecycle management
- **Status**: Discontinued due to ecosystem evolution

#### Current Approach (Foremanctl)
- **Scope**: Foreman infrastructure via containers
- **Architecture**: Container-native deployment
- **Target**: Complete infrastructure containerization
- **Status**: Active development and experimentation