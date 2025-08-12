---
title: foremanctl-parameter-mapping
type: note
permalink: installer/foremanctl-parameter-mapping
---

# Foremanctl Parameter Mapping and Configuration

**Source**: https://github.com/theforeman/foremanctl/blob/master/docs/parameters.md

## Configuration Design Principles

### Core Design Philosophy
- **Single Parameter Principle**: Use one parameter when multiple variables share the same value
- **Minimal Configuration**: "Aim for minimal configuration values for the user"
- **User-Friendly Defaults**: Reduce configuration complexity through intelligent defaults

### Parameter Translation Strategy
Systematic mapping from traditional foreman-installer parameters to container-native configuration.

## Parameter Categories

### 1. Mapped Parameters
**Status**: Successfully translated from foreman-installer
- Direct parameter mapping from existing installer
- Tested and validated configuration options
- Ready for production use

### 2. Unmapped Parameters
**Status**: Identified from documentation but not yet implemented
- Parameters exist in foreman-installer documentation
- Translation to container environment pending
- Requires development work for implementation

### 3. Undetermined Parameters
**Status**: Requires investigation and analysis
- Parameters needing further research
- Complex mapping scenarios
- Architectural decisions required

## Major Configuration Areas

### Database Configuration
Comprehensive database connectivity and management options:

#### Connection Parameters
- **Database Host**: External or internal database server
- **Database Port**: Custom port configuration
- **SSL Modes**: Database connection security options
- **Connection Credentials**: Username and password management
- **Pool Sizing**: Connection pool optimization

#### Database Management Modes
- **Internal Database**: Container-managed PostgreSQL
- **External Database**: User-managed database server
- **Hybrid Mode**: Partial external integration

#### Example Configuration
```yaml
database:
  mode: external                    # internal/external
  host: postgres.example.com
  port: 5432
  ssl_mode: require
  username: foreman
  password: "{{ vault_db_password }}"
  pool_size: 20
```

### Certificate Management
SSL/TLS certificate lifecycle and configuration:

#### Certificate Sources
- **Auto-Generated**: Automatic certificate creation
- **Custom Certificates**: User-provided certificate files
- **Let's Encrypt**: Automated certificate provisioning
- **Certificate Authority**: Internal CA integration

#### Certificate Configuration
```yaml
certificates:
  mode: custom                      # auto/custom/letsencrypt
  cert_file: /etc/ssl/foreman.crt
  key_file: /etc/ssl/foreman.key
  ca_file: /etc/ssl/ca.crt
  auto_renewal: true
```

### Smart Proxy Settings
Remote service management and configuration:

#### Proxy Services
- **DNS Management**: Domain name service integration
- **DHCP Management**: Network address allocation
- **TFTP Services**: Network boot file serving
- **Puppet Integration**: Configuration management

#### Proxy Configuration
```yaml
smart_proxy:
  enabled: true
  services:
    dns: true
    dhcp: true
    tftp: false
    puppet: true
  authentication:
    method: certificate
    trusted_hosts:
      - foreman.example.com
```

## Parameter Mapping Examples

### Traditional vs. Container Parameters

#### Database Configuration Mapping
```yaml
# Traditional foreman-installer
--foreman-db-host postgres.example.com
--foreman-db-port 5432
--foreman-db-username foreman
--foreman-db-password secret

# Foremanctl equivalent
database:
  host: postgres.example.com
  port: 5432
  username: foreman
  password: secret
```

#### Certificate Management Mapping
```yaml
# Traditional foreman-installer
--certs-server-cert /path/to/cert.pem
--certs-server-key /path/to/key.pem
--certs-server-ca-cert /path/to/ca.pem

# Foremanctl equivalent
certificates:
  server_cert: /path/to/cert.pem
  server_key: /path/to/key.pem
  ca_cert: /path/to/ca.pem
```

## Configuration Hierarchy

### Configuration Sources
1. **Default Values**: Built-in sensible defaults
2. **Configuration Files**: YAML-based configuration
3. **Environment Variables**: Container-native environment configuration
4. **Command Line**: Runtime parameter overrides

### Configuration Precedence
```
Command Line Arguments
         ↓
Environment Variables
         ↓
Configuration Files
         ↓
Default Values
```

## Advanced Configuration Patterns

### Authentication Provider Configuration
Support for external authentication systems:

#### LDAP Integration
```yaml
authentication:
  provider: ldap
  ldap:
    host: ldap.example.com
    port: 636
    encryption: ssl
    base_dn: "dc=example,dc=com"
    bind_dn: "cn=foreman,ou=services,dc=example,dc=com"
    bind_password: "{{ vault_ldap_password }}"
```

#### SAML Integration
```yaml
authentication:
  provider: saml
  saml:
    idp_sso_url: "https://idp.example.com/sso"
    idp_certificate: /etc/ssl/idp.crt
    sp_certificate: /etc/ssl/sp.crt
    sp_private_key: /etc/ssl/sp.key
```

### Logging and Performance Tuning
Operational configuration for monitoring and optimization:

#### Logging Configuration
```yaml
logging:
  level: info                       # debug/info/warn/error
  format: json                      # json/text
  destinations:
    - console
    - syslog
  log_rotation:
    enabled: true
    max_size: "100MB"
    max_files: 10
```

#### Performance Tuning
```yaml
performance:
  workers: 4                        # Application worker processes
  threads: 16                       # Threads per worker
  memory_limit: "2GB"               # Per-process memory limit
  timeout: 60                       # Request timeout seconds
```

## Container-Specific Configuration

### Resource Management
Container resource allocation and limits:

```yaml
resources:
  web:
    cpu: "1000m"                    # 1 CPU core
    memory: "2Gi"                   # 2GB RAM
    storage: "10Gi"                 # Persistent storage
  worker:
    cpu: "500m"                     # 0.5 CPU core
    memory: "1Gi"                   # 1GB RAM
  database:
    cpu: "2000m"                    # 2 CPU cores
    memory: "4Gi"                   # 4GB RAM
    storage: "50Gi"                 # Database storage
```

### Network Configuration
Container networking and service exposure:

```yaml
network:
  web:
    port: 443
    protocol: https
    load_balancer: true
  proxy:
    port: 8443
    protocol: https
    internal_only: false
  database:
    port: 5432
    internal_only: true             # Database not exposed externally
```

## Configuration Validation

### Parameter Validation Rules
- **Type Checking**: Ensure parameter types match expectations
- **Range Validation**: Numeric parameters within acceptable ranges
- **Dependency Checking**: Validate parameter interdependencies
- **Format Validation**: String parameters match required formats

### Example Validation
```yaml
validation:
  database:
    host:
      type: string
      required: true
      format: hostname
    port:
      type: integer
      range: [1, 65535]
      default: 5432
  certificates:
    server_cert:
      type: file_path
      required_when: "certificates.mode == 'custom'"
```

## Environment-Specific Configuration

### Development Configuration
```yaml
environment: development
debug:
  enabled: true
  sql_logging: true
  verbose_errors: true
security:
  ssl_verify: false
  session_timeout: 3600
```

### Production Configuration
```yaml
environment: production
debug:
  enabled: false
security:
  ssl_verify: true
  session_timeout: 1800
  hsts_enabled: true
performance:
  cache_enabled: true
  asset_compression: true
```

## Migration and Compatibility

### Configuration Migration Tools
- **Parameter Translation**: Automatic conversion from foreman-installer configs
- **Validation**: Ensure migrated configuration is valid
- **Backup**: Preserve original configuration for rollback

### Backward Compatibility
- **Legacy Parameter Support**: Gradual deprecation of old parameters
- **Migration Warnings**: Notify users of deprecated configurations
- **Documentation**: Clear migration guides and examples
## Complete Parameter Documentation Analysis

### Parameter Mapping Tables
Based on the comprehensive parameter documentation, the foremanctl project includes detailed mapping tables showing the transition from foreman-installer parameters to the new container-based system.

### Database Parameter Mapping
**Key Database Parameters Identified:**
- `--database-mode`: Internal vs external database management
- `--database-host`: Database server hostname
- `--database-port`: Database connection port
- `--database-ssl-mode`: SSL connection configuration

### Multi-Database Support
The parameter system supports separate database configurations for:
- **Foreman Database**: Core application database
- **Candlepin Database**: Subscription management database  
- **Pulp Database**: Content management database

### Parameter Categories Status

#### Mapped Parameters (Ready for Implementation)
Parameters that have direct translation from foreman-installer and are ready for use in the container-based installer.

#### Unmapped Parameters (Development Required)
Parameters from foreman-installer that exist in documentation but haven't yet been mapped to the new installer system. These require additional development work.

#### Undetermined Parameters (Investigation Needed)
Parameters that require further analysis to determine:
- **Relevance**: Whether the parameter is still needed in container environment
- **Implementation**: How to best implement in container context
- **Dependencies**: Parameter interdependencies and conflicts

### Configuration Flexibility Goals
The parameter system emphasizes:
- **User-Friendly Defaults**: Minimizing required user configuration
- **Single Parameter Principle**: Avoiding redundant configuration options
- **Comprehensive Coverage**: Supporting all major configuration scenarios from traditional installer

### Enterprise Integration Parameters
Support for enterprise-specific configuration including:
- **External Database Configuration**: Full external database connectivity
- **SSL/TLS Management**: Comprehensive certificate and encryption options
- **Authentication Systems**: LDAP, SAML, and other enterprise authentication
- **Network Configuration**: Proxy, firewall, and network policy integration