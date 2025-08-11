---
title: installer-component-patterns
type: note
permalink: installer/installer-component-patterns
---

# Installer Component Patterns

## Core Component Architecture

The foreman-installer is built on the **Kafo framework** and follows established patterns for managing complex multi-service deployments through modular Puppet-based components.

## Kafo Integration Patterns

### Parameter Discovery Pattern
Kafo automatically discovers parameters from Puppet manifests:
```puppet
# Puppet class with auto-discovered parameters
class foreman (
  String $servername = $facts['networking']['fqdn'],
  Boolean $ssl = true,
  Sensitive[String] $db_password = Sensitive('changeme'),
) {
  # Implementation
}
```

### Dynamic CLI Generation
```bash
# Auto-generated CLI from Puppet parameters
foreman-installer --foreman-servername=myhost.example.com \
                  --foreman-ssl=true \
                  --foreman-db-password=secret
```

### Interactive Configuration Pattern
```ruby
# Kafo interactive mode with parameter grouping
Kafo::App.run do |app|
  app.param('foreman', 'servername').ask('Server hostname')
  app.param('foreman', 'ssl').ask('Enable SSL?')
end
```

## Service Management Patterns

### Service Enablement Pattern
```yaml
# Standard pattern for enabling/disabling services
foreman_proxy_dhcp: true
foreman_proxy_dns: true
foreman_proxy_tftp: false
```

### Configuration Inheritance
- **Base Classes**: Common configuration shared across components
- **Service-Specific**: Component-specific parameter overrides
- **Environment Overrides**: Development, staging, production variants

## Puppet Module Integration Patterns

### Module Composition
The installer orchestrates multiple Puppet modules:
- **puppet-foreman**: Core Foreman application
- **puppet-foreman_proxy**: Smart Proxy services
- **puppet-puppet**: Puppet server configuration
- **puppet-apache**: Web server setup
- **puppet-postgresql**: Database management

### Parameter Mapping
```ruby
# Pattern for mapping installer parameters to module parameters
class { 'foreman':
  db_host     => $foreman_db_host,
  db_password => $foreman_db_password,
  ssl         => $foreman_ssl,
}
```

## Configuration Management Patterns

### Scenario-Based Configuration
- **Default Scenario**: Standard all-in-one setup
- **Custom Scenarios**: Environment-specific configurations
- **Inheritance Chain**: Base → Scenario → CLI → Interactive

### Answer File Pattern
```yaml
# Standard answer file structure
foreman:
  custom-hiera: /etc/foreman-installer/custom-hiera.yaml
  installer_dir: /usr/share/foreman-installer
  module_dir: /usr/share/foreman-installer/modules
  
foreman_proxy:
  custom-hiera: /etc/foreman-installer/custom-hiera.yaml
```

## Hook System Patterns

### Pre/Post Installation Hooks
- **pre_values**: Parameter validation and preprocessing
- **pre_validations**: System requirement checks
- **post**: Service configuration and cleanup

### Hook Implementation Pattern
```ruby
# Kafo hook registration pattern
Kafo::HookContext.execute(:pre_values) do |context|
  # Access to app context and parameters
  app = context.app
  
  # Parameter validation and preprocessing
  if app.params['foreman_ssl'].value
    app.params['foreman_ssl_cert'].value ||= generate_cert_path
  end
  
  # System validation
  check_system_requirements(context)
end
```

## Validation Patterns

### Multi-Level Validation
1. **Syntax Validation**: YAML structure and parameter types
2. **Semantic Validation**: Cross-parameter consistency
3. **System Validation**: Resource availability and conflicts
4. **Runtime Validation**: Service connectivity and functionality

### Error Handling Pattern
- **Graceful Degradation**: Continue installation where possible
- **Clear Messaging**: User-friendly error descriptions
- **Recovery Guidance**: Suggested actions for common issues

## Certificate Management Patterns

### SSL Certificate Lifecycle
- **Generation**: Automatic CA and certificate creation
- **Distribution**: Secure certificate deployment across services
- **Renewal**: Automated certificate rotation
- **Validation**: Certificate chain and expiration checking

### Certificate Pattern Implementation
```ruby
# Certificate management pattern
class { 'certs':
  generate => true,
  deploy   => true,
  ca_cert  => '/etc/foreman-proxy/ssl_ca.pem',
}
```

## Plugin Integration Patterns

### Plugin Discovery
- **Module Scanning**: Automatic detection of available plugins
- **Dependency Resolution**: Plugin requirement validation
- **Configuration Merging**: Plugin-specific parameter integration

### Plugin Configuration Pattern
```yaml
# Plugin enablement pattern
foreman::plugin::discovery: true
foreman::plugin::remote_execution: true
foreman::plugin::ansible: false
```

## Database Management Patterns

### Database Setup Pattern
- **Local Database**: PostgreSQL on same host
- **Remote Database**: External database connection
- **Migration Handling**: Schema updates and data migration

### Database Configuration
```puppet
# Database management pattern
class { 'postgresql::server':
  listen_addresses => $postgresql_listen_addresses,
}

postgresql::server::db { 'foreman':
  user     => $foreman_db_user,
  password => $foreman_db_password,
}
```

## Service Discovery Patterns

### Smart Proxy Registration
- **Automatic Registration**: Self-registration with Foreman
- **Feature Detection**: Capability advertisement
- **Health Monitoring**: Service status reporting

### Load Balancer Integration
- **Health Checks**: Service availability endpoints
- **Configuration Distribution**: Load balancer configuration updates
- **Service Mesh**: Integration with modern service discovery

## Development and Testing Patterns

### Development Mode Configuration
- **Debug Enablement**: Increased logging and debugging
- **Security Relaxation**: Development-friendly security settings
- **Rapid Iteration**: Fast deployment and testing cycles

### Testing Infrastructure
- **Unit Testing**: Component-level validation
- **Integration Testing**: Multi-service interaction testing
- **Acceptance Testing**: End-to-end scenario validation

## Deployment Patterns

### Rolling Updates
- **Service Ordering**: Dependency-aware update sequencing
- **Health Validation**: Service health checks between updates
- **Rollback Capability**: Quick recovery from failed updates

### High Availability Patterns
- **Active/Passive**: Primary/backup service configuration
- **Load Distribution**: Multi-node load balancing
- **Data Replication**: Database and file system synchronization