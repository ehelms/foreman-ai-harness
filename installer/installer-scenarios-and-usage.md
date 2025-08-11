---
title: installer-scenarios-and-usage
type: note
permalink: installer/installer-scenarios-and-usage
---

# Installer Scenarios and Usage

Based on official Foreman documentation and sources.

## Installation Scenarios

### 1. Foreman Server Installation

**Source**: [Foreman Installation Guide](https://docs.theforeman.org/nightly/Installing_Server/index-foreman-el.html)

#### Basic Installation
```bash
# Install foreman-installer package
yum install -y foreman-installer

# Run basic installation
foreman-installer \
  --foreman-initial-organization "My Organization" \
  --foreman-initial-location "My Location" \
  --foreman-initial-admin-username admin \
  --foreman-initial-admin-password password
```

#### System Requirements
- **Architecture**: x86_64 only
- **CPU**: Minimum 4-core 2.0 GHz
- **Memory**: 4 GB RAM minimum (more recommended for production)
- **DNS**: Full forward and reverse DNS resolution required
- **SELinux**: Must be enabled (enforcing or permissive)
- **Time Sync**: Synchronized system clock required

#### Supported Operating Systems
- Enterprise Linux 9 (x86_64)
- Fresh system installation recommended

### 2. Katello Installation Scenario

**Source**: [Katello Installation Documentation](https://github.com/theforeman/foreman-installer/blob/develop/KATELLO.md)

#### Basic Katello Installation
```bash
# Install Katello variant
yum install -y foreman-installer-katello

# Run Katello scenario
foreman-installer --scenario katello
```

#### Advanced Katello Configuration
```bash
# Katello with additional services
foreman-installer --scenario katello \
  --enable-foreman-proxy \
  --foreman-proxy-dns true \
  --foreman-proxy-dhcp true \
  --foreman-proxy-tftp true
```

#### Katello Features
- **Content Management**: RPM, container, and file repositories
- **Certificate Management**: Custom CA or default certificates
- **Proxy Services**: DNS, DHCP, TFTP integration
- **Reset Capability**: Complete system reset with `--reset` flag

### 3. Smart Proxy Scenarios

#### Foreman Proxy Content
```bash
# Content proxy for distributed environments
foreman-installer --scenario foreman-proxy-content \
  --foreman-proxy-content-parent-fqdn foreman.example.com \
  --foreman-proxy-register-in-foreman true
```

#### Capsule Server
```bash
# Smart proxy with content capabilities
foreman-installer --scenario capsule \
  --capsule-parent-fqdn foreman.example.com
```

## Configuration Methods

### Command-Line Parameters
All Puppet module parameters are exposed as CLI options:
```bash
foreman-installer \
  --foreman-servername myhost.example.com \
  --foreman-ssl true \
  --foreman-db-password secret \
  --enable-foreman-proxy \
  --foreman-proxy-dns true
```

### Answer Files
Configuration persisted in scenario-specific files:
- **Foreman**: `/etc/foreman-installer/scenarios.d/foreman-answers.yaml`
- **Katello**: `/etc/foreman-installer/scenarios.d/katello-answers.yaml`

### Interactive Mode
```bash
# Interactive configuration
foreman-installer --interactive
```

## Advanced Configuration Options

### External Database
```bash
foreman-installer \
  --foreman-db-manage false \
  --foreman-db-host db.example.com \
  --foreman-db-username foreman \
  --foreman-db-password secret
```

### Custom Certificates
```bash
foreman-installer \
  --certs-server-cert /path/to/server.crt \
  --certs-server-key /path/to/server.key \
  --certs-server-ca-cert /path/to/ca.crt
```

### HTTP Proxy Configuration
```bash
foreman-installer \
  --foreman-proxy-http-proxy http://proxy.example.com:8080 \
  --foreman-proxy-ssl-proxy https://proxy.example.com:8443
```

### Email Configuration
```bash
foreman-installer \
  --foreman-email-delivery-method smtp \
  --foreman-email-smtp-address smtp.example.com \
  --foreman-email-smtp-port 587 \
  --foreman-email-smtp-authentication login \
  --foreman-email-smtp-user-name user@example.com \
  --foreman-email-smtp-password secret
```

## Development Installation

### Git-Based Installation
```bash
# Clone with submodules
git clone --recursive https://github.com/theforeman/foreman-installer.git
cd foreman-installer

# Install dependencies
bundle install

# Install Puppet modules
librarian-puppet install

# Run development installer
./bin/foreman-installer --scenario katello
```

## Data Management and Reset

### Complete System Reset
```bash
# Reset entire Katello installation
foreman-installer --scenario katello --reset
```

### Selective Content Clearing
```bash
# Clear Pulp content only
foreman-installer --scenario katello --reset-data

# Clear Puppet environments
foreman-installer --scenario katello --clear-puppet-environments
```

## Best Practices

### Pre-Installation
- Use freshly provisioned systems
- Ensure proper DNS resolution
- Verify system requirements
- Plan certificate strategy

### Post-Installation
- Regular backups of answer files
- Monitor system resources
- Plan for scaling and growth
- Document custom configurations

### Operational Considerations
- **Conflict Avoidance**: Installer may overwrite manual configurations
- **User Management**: Avoid conflicts with predefined system users
- **Security**: Follow certificate management best practices
- **Updates**: Use installer for configuration changes rather than manual edits