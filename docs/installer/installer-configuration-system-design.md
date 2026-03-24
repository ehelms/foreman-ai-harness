---
title: installer-configuration-system-design
type: note
permalink: installer/installer-configuration-system-design
---

# Installer Configuration System Design

## Configuration Architecture

The foreman-installer leverages the **Kafo framework** to provide a sophisticated **scenario-based configuration system** that automatically discovers parameters from Puppet modules and provides flexibility while maintaining simplicity for common use cases.

## Kafo-Powered Configuration Discovery

### Automatic Parameter Extraction
Kafo reads Puppet manifests to automatically discover:
- **Parameter Names**: All class parameters become installer options
- **Data Types**: Full Puppet type system support (String, Boolean, Hash, Sensitive, etc.)
- **Default Values**: Extracted directly from Puppet class definitions
- **Documentation**: Parameter descriptions from Puppet doc comments
- **Validation Rules**: Inherits Puppet parameter validation constraints

## Answer Files System

### Location and Structure
- **Primary Path**: `/etc/foreman-installer/scenarios.d/foreman-answers.yaml`
- **Format**: YAML-based configuration
- **Persistence**: Configuration is saved and reused across runs
- **Version Control**: Enables configuration management and rollback

### Configuration Hierarchy
1. **Default Values**: Built-in module defaults
2. **Scenario Files**: Predefined configuration templates
3. **CLI Arguments**: Runtime parameter overrides
4. **Interactive Input**: User-provided values during installation

## Modular Configuration Approach

### Component-Level Configuration
Each major component has its own configuration namespace:

- **Foreman Core**: Web application settings, database configuration
- **Smart Proxy**: Service endpoints, authentication, feature flags
- **Puppet Server**: Master configuration, environment settings
- **Optional Services**: DHCP, DNS, TFTP specific parameters

### Parameter Categories
- **Service Enablement**: Which components to install/configure
- **Network Configuration**: Ports, hostnames, SSL settings
- **Authentication**: User accounts, certificates, tokens
- **Feature Flags**: Plugin activation, experimental features
- **Resource Allocation**: Memory limits, worker processes

## Installation Scenarios

### Predefined Scenarios
1. **foreman**: Standard all-in-one installation
2. **katello**: Content management with Foreman
3. **foreman-proxy-content**: Content proxy for distributed setups
4. **capsule**: Smart proxy with content capabilities

### Custom Scenarios
- **Template System**: Create new scenarios based on existing ones
- **Parameter Override**: Modify specific settings while inheriting base configuration
- **Environment-Specific**: Development, staging, production variants

## Configuration Validation

### Pre-Installation Checks
- **System Requirements**: Memory, disk space, OS version
- **Network Connectivity**: Port availability, hostname resolution
- **Dependency Verification**: Required packages and services
- **Conflict Detection**: Existing service conflicts

### Runtime Validation
- **Parameter Consistency**: Cross-component configuration validation
- **Security Constraints**: Certificate validity, permission checks
- **Resource Availability**: Database connectivity, file system access

## Interactive Configuration Mode

### Guided Setup Process
1. **Component Selection**: Choose which services to install
2. **Basic Configuration**: Hostname, passwords, certificates
3. **Advanced Options**: Plugin selection, performance tuning
4. **Review and Confirm**: Configuration summary before execution

### User Experience Features
- **Intelligent Defaults**: Reasonable values for most parameters
- **Contextual Help**: Explanations for complex configuration options
- **Validation Feedback**: Real-time parameter validation
- **Progress Indication**: Clear feedback during installation process

## Configuration Management Integration

### Puppet Integration
- **Module Parameters**: Direct mapping to Puppet module parameters
- **Hiera Compatibility**: Works with existing Hiera hierarchies
- **Class Declaration**: Automatic generation of Puppet class declarations

### External Configuration Sources
- **Environment Variables**: Support for containerized deployments
- **Configuration Management**: Integration with existing CM tools
- **API Configuration**: Programmatic configuration updates

## Advanced Configuration Patterns

### Multi-Host Deployments
- **Host-Specific Scenarios**: Different configurations per host
- **Service Distribution**: Components across multiple servers
- **Load Balancing**: Configuration for high-availability setups

### Development and Testing
- **Development Mode**: Reduced security, debugging enabled
- **Test Scenarios**: Minimal installations for testing
- **CI/CD Integration**: Automated configuration for pipelines

## Configuration Best Practices

### Security Considerations
- **Credential Management**: Secure storage of passwords and keys
- **Certificate Handling**: Automated certificate generation and renewal
- **Access Control**: Proper file permissions and ownership

### Operational Excellence
- **Configuration Backup**: Regular backup of answer files
- **Change Tracking**: Version control for configuration changes
- **Documentation**: Clear documentation of custom configurations
- **Monitoring**: Configuration drift detection and alerting
## References

- **Foreman Installation Guide**: https://docs.theforeman.org/nightly/Installing_Server/index-foreman-el.html
- **Katello Installation**: https://github.com/theforeman/foreman-installer/blob/develop/KATELLO.md
- **Kafo Framework**: https://github.com/theforeman/kafo