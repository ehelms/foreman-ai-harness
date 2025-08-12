---
title: foremanctl-installation-workflow
type: note
permalink: installer/foremanctl-installation-workflow
---

# Foremanctl Installation Workflow

**Source**: https://raw.githubusercontent.com/theforeman/foremanctl/f703e1c3ff36353dd7497e2780669da34bfa97bd/docs/installation.md

## Installation Design Philosophy

### Dual-Path Installation Strategy
The foremanctl installer provides two distinct installation approaches to accommodate different user needs and operational requirements.

## Installation Paths

### Happy Path (Minimal Deployment)
**Target**: Simple, streamlined installation for standard deployments

#### Workflow Steps
1. **Repository Configuration**: Configure package repositories
2. **Package Installation**: Install foremanctl package
3. **Run Installer**: Execute installation with minimal configuration

#### Use Cases
- **Development Environments**: Quick setup for testing and development
- **Standard Deployments**: Default configurations with minimal customization
- **First-Time Users**: Simplified onboarding experience

#### Benefits
- **Reduced Complexity**: Minimal decision points for users
- **Fast Deployment**: Streamlined installation process
- **Lower Barrier to Entry**: Easy adoption for new users

### Advanced Path (Detailed Management)
**Target**: Comprehensive installation with full control over deployment process

#### Detailed Workflow Steps

##### 1. RPM Repository Configuration
- Configure package repositories for dependencies
- Verify repository accessibility and credentials
- Establish package source priorities

##### 2. Container Image Management
- **Image Pulling**: Pre-pull required container images
- **Registry Authentication**: Handle authenticated registry access
- **Image Verification**: Validate image integrity and signatures

##### 3. Certificate Generation and Management
- **SSL Certificate Creation**: Generate or import SSL certificates
- **Certificate Authority Setup**: Establish CA infrastructure
- **Certificate Distribution**: Deploy certificates to appropriate services

##### 4. Pre-requisite System Checks
- **System Requirements**: Validate hardware and software prerequisites
- **Network Connectivity**: Verify network access and DNS resolution
- **Resource Availability**: Check CPU, memory, and storage requirements
- **Service Conflicts**: Detect conflicting services or ports

##### 5. Configuration and Deployment
- **Parameter Validation**: Validate installation parameters
- **Configuration File Placement**: Deploy service configuration files
- **Podman Secret Creation**: Create and manage container secrets
- **Service Management**: Start and configure systemd services

##### 6. Post-Installation Verification
- **Service Health Checks**: Verify all services are running correctly
- **Connectivity Testing**: Test service communication and endpoints
- **Functional Validation**: Perform basic functionality tests
- **Performance Verification**: Validate system performance benchmarks

#### Use Cases
- **Production Deployments**: Full control over production environments
- **Complex Configurations**: Custom networking, security, or integration requirements
- **Enterprise Environments**: Compliance and security-focused installations
- **Troubleshooting**: Detailed control for diagnosing installation issues

## Authenticated Registry Support

### Registry Authentication Scenarios
The installer accommodates various container registry authentication requirements:

#### Public Registry Access
- **Default Configuration**: Access to public container registries
- **No Authentication**: Standard public image access patterns

#### Authenticated Registry Access
- **Username/Token Authentication**: Support for private registry access
- **Registry Login Management**: Automated registry authentication
- **Credential Management**: Secure handling of registry credentials

#### Custom Image Sources
- **Private Registries**: Enterprise container registry integration
- **Custom Image Builds**: Support for organization-specific images
- **Mirror Configurations**: Registry mirror and cache support

### Registry Configuration Examples
```bash
# Public registry (default)
foremanctl deploy

# Authenticated registry
foremanctl deploy --registry-username myuser --registry-token mytoken

# Custom registry
foremanctl deploy --registry-url registry.company.com
```

## Installer Stage Architecture

### Core Installation Stages

#### 1. Input Parameter Processing
- **Parameter Acceptance**: Collect user-provided configuration parameters
- **Parameter Validation**: Validate parameter format, types, and constraints
- **Default Value Application**: Apply intelligent defaults for unspecified parameters
- **Conflict Resolution**: Resolve parameter conflicts and dependencies

#### 2. Pre-requisite System Checks
- **Hardware Validation**: Verify CPU, memory, and storage requirements
- **Software Dependencies**: Check for required system packages and services
- **Network Requirements**: Validate network connectivity and DNS resolution
- **Security Prerequisites**: Verify SELinux, firewall, and permission requirements

#### 3. Configuration Management
- **Configuration File Generation**: Create service-specific configuration files
- **Template Processing**: Process configuration templates with user parameters
- **File Placement**: Deploy configuration files to appropriate locations
- **Permission Management**: Set correct file permissions and ownership

#### 4. Secret and Credential Management
- **Podman Secret Creation**: Create container secrets for sensitive data
- **Certificate Deployment**: Install and configure SSL/TLS certificates
- **Database Credential Setup**: Configure database authentication
- **Service Authentication**: Set up inter-service authentication

#### 5. Service Deployment and Management
- **Container Image Preparation**: Pull and verify container images
- **Systemd Service Creation**: Generate systemd service definitions
- **Service Startup**: Start and enable required systemd services
- **Dependency Resolution**: Ensure proper service startup order

#### 6. Post-Installation Verification
- **Health Check Execution**: Verify service health and functionality
- **Connectivity Testing**: Test inter-service communication
- **API Endpoint Validation**: Verify web interface and API accessibility
- **Integration Testing**: Validate end-to-end functionality

## Configuration Management Strategy

### Configuration Source Hierarchy
**Priority Order** (highest to lowest):

#### 1. Native Environment Variables
- **Direct Environment Variables**: OS-level environment variable configuration
- **Container Environment**: Container-specific environment variables
- **Service Environment**: Service-level environment variable overrides

#### 2. Environment Variable Substitution
- **Template Substitution**: Environment variable replacement in configuration templates
- **Dynamic Configuration**: Runtime configuration parameter substitution
- **Conditional Configuration**: Environment-based configuration logic

#### 3. Secrets-Based File Mounting
- **Podman Secrets**: Secure file content delivery via secrets
- **Configuration Files**: Complete configuration file deployment via secrets
- **Credential Files**: Secure credential file distribution

### Configuration Best Practices

#### Environment Variable Usage
```bash
# Service configuration
export FOREMAN_SERVERNAME=foreman.example.com
export FOREMAN_SSL_ENABLED=true
export DATABASE_HOST=postgres.example.com

# Deploy with environment variables
foremanctl deploy
```

#### Secret-Based Configuration
```bash
# Create configuration secrets
podman secret create foreman-database-yml /tmp/database.yml
podman secret create foreman-ssl-cert /etc/ssl/foreman.crt

# Deploy with secrets
foremanctl deploy --use-secrets
```

#### Template-Based Configuration
```yaml
# configuration template with substitution
database:
  host: ${DATABASE_HOST:-localhost}
  port: ${DATABASE_PORT:-5432}
  username: ${DATABASE_USER:-foreman}
  password: ${DATABASE_PASSWORD}
```

## Deployment Scenarios

### Standard Enterprise Deployment
```bash
# Advanced path enterprise deployment
foremanctl deploy \
  --installation-path advanced \
  --registry-url registry.company.com \
  --database-host postgres.company.com \
  --certificate-source custom \
  --ssl-cert /etc/ssl/company.crt \
  --ssl-key /etc/ssl/company.key
```

### Development Environment
```bash
# Happy path development deployment
foremanctl deploy \
  --installation-path happy \
  --environment development \
  --debug-enabled true
```

### High-Availability Deployment
```bash
# Advanced path HA deployment
foremanctl deploy \
  --installation-path advanced \
  --database-mode external \
  --database-host postgres-cluster.company.com \
  --load-balancer-enabled true \
  --replica-count 3
```

## Troubleshooting and Validation

### Installation Validation
- **Pre-flight Checks**: Comprehensive system validation before installation
- **Stage Validation**: Verification at each installation stage
- **Post-installation Testing**: Complete functionality validation

### Common Installation Scenarios
- **Network Issues**: DNS resolution and connectivity problems
- **Permission Problems**: File system and service permission issues
- **Resource Constraints**: Insufficient system resources
- **Configuration Errors**: Invalid or conflicting configuration parameters

### Recovery and Rollback
- **Installation Rollback**: Ability to revert installation changes
- **Configuration Backup**: Automatic backup of original configuration
- **Service Recovery**: Recovery procedures for failed services
- **Diagnostic Tools**: Built-in troubleshooting and diagnostic capabilities

## Integration with Existing Infrastructure

### External Service Integration
- **Database Integration**: External PostgreSQL database connectivity
- **LDAP Integration**: Enterprise directory service authentication
- **Load Balancer Integration**: Enterprise load balancing solutions
- **Monitoring Integration**: Enterprise monitoring and alerting systems

### Security and Compliance
- **Certificate Management**: Enterprise PKI integration
- **Security Policies**: Compliance with organizational security policies
- **Audit Logging**: Installation and configuration audit trails
- **Access Control**: Role-based access control for installation procedures