---
title: foremanctl-issues-and-concerns
type: note
permalink: installer/foremanctl-issues-and-concerns
---

# Foremanctl Issues and Development Concerns

## GitHub Issues Analysis

Based on examination of the foremanctl repository issues, several key areas of concern and development priorities have emerged.

## Security and Cryptography Concerns

### Post-Quantum Cryptography
- **Issue**: Support for post-quantum cryptography algorithms
- **Concern**: Future-proofing against quantum computing threats
- **Impact**: Long-term security of Foreman deployments
- **Status**: Under consideration for implementation

### Crypto Policy Management
- **Issue**: "Deal with crypto policies"
- **Concern**: Compliance with organizational and regulatory crypto requirements
- **Impact**: Enterprise deployment compatibility
- **Consideration**: Need for flexible crypto policy configuration

### PostgreSQL Authentication Security
- **Issue**: SCRAM-SHA-256 authentication method
- **Concern**: Moving beyond legacy password authentication
- **Impact**: Database security hardening
- **Benefit**: Stronger authentication mechanisms

## Testing and Quality Assurance

### Test Infrastructure Expansion
- **Issue**: "Add Molecule Testing"
- **Concern**: Need for comprehensive testing framework
- **Impact**: Reliability and stability of container deployments
- **Approach**: Integration of Ansible testing tools

### Testing Tool Evaluation
- **Issue**: Interest in 'tmt' testing tool
- **Concern**: Finding appropriate testing methodologies for container infrastructure
- **Impact**: CI/CD pipeline effectiveness
- **Consideration**: Standardized testing approaches

## Operational and Configuration Challenges

### Service Management
- **Issue**: Managing service restarts in containerized environments
- **Concern**: Graceful service lifecycle management
- **Impact**: Deployment reliability and user experience
- **Complexity**: Container orchestration vs. traditional service management

### Certificate Management
- **Issue**: Services to ensure certificate presence
- **Concern**: SSL/TLS certificate lifecycle in containers
- **Impact**: Security and service availability
- **Requirement**: Automated certificate provisioning and renewal

### Debug and Logging
- **Issue**: Handling debug logging and conditional output
- **Concern**: Troubleshooting and diagnostic capabilities
- **Impact**: Operational visibility and problem resolution
- **Need**: Structured logging and debug controls

## Database and Persistence

### PostgreSQL Management
- **Issue**: PostgreSQL connection configuration and upgrades
- **Concern**: Database lifecycle management in containers
- **Impact**: Data integrity and service continuity
- **Complexity**: Stateful services in container environments

### Connection Pooling
- **Issue**: Exploring PgBouncer for connection management
- **Concern**: Database performance and connection efficiency
- **Impact**: Scalability and resource utilization
- **Benefit**: Improved database connection handling

## Infrastructure Migration Challenges

### Recurring Task Management
- **Issue**: Managing tasks previously handled by cronjobs
- **Concern**: Scheduled task execution in container environments
- **Impact**: Maintenance operations and automated processes
- **Solution Needed**: Container-native scheduling mechanisms

### Secret Management
- **Issue**: Handling secret updates in Podman
- **Concern**: Dynamic secret rotation and updates
- **Impact**: Security operations and credential management
- **Requirement**: Automated secret lifecycle management

## Installer Experience Improvements

### Installation Feedback
- **Issue**: Post-installation messaging
- **Concern**: User experience and installation guidance
- **Impact**: Adoption and user satisfaction
- **Need**: Clear installation status and next steps

### Standalone Operations
- **Issue**: Standalone command checks
- **Concern**: Independent operation validation
- **Impact**: Installation reliability and debugging
- **Requirement**: Self-contained validation tools

### Static Asset Serving
- **Issue**: Static asset serving configuration
- **Concern**: Web application performance and resource delivery
- **Impact**: User interface performance
- **Consideration**: CDN integration and caching strategies

## Container Infrastructure Concerns

### Image Security and Scanning
- **Implicit Concern**: Container image vulnerability management
- **Impact**: Security posture of deployments
- **Requirement**: Automated image scanning and updates
- **Consideration**: Base image selection and maintenance

### Resource Management
- **Implicit Concern**: Container resource allocation and limits
- **Impact**: System performance and stability
- **Requirement**: Resource governance and monitoring
- **Consideration**: Multi-tenant resource isolation

### Container Registry Management
- **Implicit Concern**: Container image distribution and storage
- **Impact**: Deployment scalability and reliability
- **Requirement**: Registry strategy and mirror configuration
- **Consideration**: Private registry integration

## Development Workflow Challenges

### Environment Consistency
- **Concern**: Development vs. production environment parity
- **Impact**: Development productivity and deployment confidence
- **Requirement**: Consistent containerized development environments
- **Approach**: Docker/Podman development workflows

### Configuration Management
- **Concern**: Managing complex configuration across environments
- **Impact**: Deployment flexibility and maintainability
- **Requirement**: Hierarchical configuration management
- **Approach**: Environment-specific parameter overrides

### Testing Coverage
- **Concern**: Comprehensive testing of container-based deployments
- **Impact**: Release quality and regression prevention
- **Requirement**: Multi-layer testing strategy
- **Approach**: Unit, integration, and acceptance testing

## Integration and Compatibility

### Smart Proxy Integration
- **Concern**: Smart Proxy deployment in container environments
- **Impact**: Distributed Foreman architectures
- **Requirement**: Container-native Smart Proxy deployment
- **Consideration**: Network and service discovery patterns

### External Service Integration
- **Concern**: Integration with external databases, LDAP, etc.
- **Impact**: Enterprise integration capabilities
- **Requirement**: Flexible external service configuration
- **Consideration**: Network policies and security boundaries

### Migration Path Planning
- **Concern**: Migration from traditional installations
- **Impact**: Adoption rate and transition complexity
- **Requirement**: Migration tooling and documentation
- **Consideration**: Backward compatibility and data migration

## Performance and Scalability

### Container Overhead
- **Concern**: Performance impact of containerization
- **Impact**: Resource utilization and response times
- **Requirement**: Performance benchmarking and optimization
- **Consideration**: Container runtime selection and tuning

### Horizontal Scaling
- **Concern**: Multi-instance deployment patterns
- **Impact**: Load handling and availability
- **Requirement**: Load balancing and session management
- **Consideration**: Stateless application design

## Monitoring and Observability

### Health Checking
- **Concern**: Container and application health monitoring
- **Impact**: Service reliability and problem detection
- **Requirement**: Comprehensive health check implementation
- **Approach**: Multi-level health validation

### Metrics and Logging
- **Concern**: Observability in containerized environments
- **Impact**: Operational visibility and troubleshooting
- **Requirement**: Centralized logging and metrics collection
- **Consideration**: Integration with monitoring platforms