---
title: container-image-build-strategy
type: note
permalink: installer/container-image-build-strategy
---

# Container Image Build Strategy

**Source**: https://github.com/theforeman/foremanctl/blob/master/docs/container-image-builds.md

## Official Container Strategy

### Container Registry Plan
All container images will be hosted at **quay.io/foreman/$service:$tag**

### Container Image Variants
Three distinct container flavors will be produced:

1. **Vanilla Foreman**: Core Foreman functionality only
2. **Foreman + Katello**: Content management integration
3. **Foreman + All Plugins**: Comprehensive feature set

### Base Image Architecture
- **Base Image**: `quay.io/centos/centos:stream9`
- **Staging Images**: `quay.io/foreman/$service-stage:$tag`

## Repository Structure

### Dedicated OCI Repositories
Container image definitions will be stored in dedicated repositories following packaging patterns:

1. **foreman-oci-images**: Core Foreman container definitions
2. **pulp-oci-images**: Pulp content management containers
3. **candlepin-oci-images**: Subscription management containers

### Repository Mimicking Strategy
The OCI repositories will mirror the existing packaging repository structure, providing consistency between traditional and container-based deployment methods.

## Tagging Strategy

### Release Container Image Tags
**Format**: Multiple concurrent tags per release

#### Project Version Tags
- **Full Version**: `X.Y.Z` (e.g., `3.12.1`)
- **Minor Version**: `X.Y` (e.g., `3.12`)

#### Foreman Version Tags
- **Full Foreman Version**: `foreman-X.Y.Z` (e.g., `foreman-3.12.1`)
- **Minor Foreman Version**: `foreman-X.Y` (e.g., `foreman-3.12`)

#### Example Release Tagging
```bash
# For Foreman 3.12.1 release
quay.io/foreman/foreman:3.12.1
quay.io/foreman/foreman:3.12
quay.io/foreman/foreman:foreman-3.12.1
quay.io/foreman/foreman:foreman-3.12
```

### Nightly Container Image Tags
**Purpose**: Development and testing builds

#### Nightly Tags
- **Nightly Build**: `nightly`
- **Development Version**: `X.Y.Z` (development builds)

#### Example Nightly Tagging
```bash
# For nightly builds
quay.io/foreman/foreman:nightly
quay.io/foreman/foreman:3.13.0  # Pre-release development
```

## Service Container Architecture

### Container Service Breakdown
Based on the OCI repository structure:

#### Core Foreman Services
```bash
# Core Foreman containers
quay.io/foreman/foreman:$tag           # Main application
quay.io/foreman/foreman-proxy:$tag     # Smart Proxy services
```

#### Content Management Services
```bash
# Pulp containers for content management
quay.io/foreman/pulp:$tag              # Content repository
quay.io/foreman/pulp-worker:$tag       # Background processing
```

#### Subscription Management
```bash
# Candlepin containers for subscriptions
quay.io/foreman/candlepin:$tag         # Subscription services
```

## Build Pipeline Strategy

### Staging and Production Pipeline
- **Stage Images**: `quay.io/foreman/$service-stage:$tag`
- **Production Images**: `quay.io/foreman/$service:$tag`

### Quality Gates
1. **Stage Build**: Initial container build and basic testing
2. **Stage Validation**: Comprehensive testing in staging environment
3. **Production Promotion**: Promotion of validated stage images

## Container Variant Strategy

### Vanilla Foreman
**Target**: Minimal Foreman installation
- Core Foreman application
- Essential plugins only
- Lightweight deployment option

### Foreman + Katello
**Target**: Content management deployment
- Foreman core application
- Katello content management
- Pulp integration
- Enterprise content workflows

### Foreman + All Plugins
**Target**: Full-featured deployment
- Complete plugin ecosystem
- Maximum functionality
- Development and testing environments

## Image Optimization Strategy

### Multi-Stage Build Approach
```dockerfile
# Example build strategy
FROM quay.io/centos/centos:stream9 AS builder
# Build dependencies and compilation

FROM quay.io/centos/centos:stream9 AS runtime
# Runtime dependencies and application
COPY --from=builder /opt/foreman /opt/foreman
```

### Layer Optimization
- **Base Layer**: Common dependencies across all variants
- **Service Layer**: Service-specific components
- **Configuration Layer**: Environment-specific configuration

## Distribution Strategy

### Registry Architecture
- **Primary Registry**: quay.io/foreman (public registry)
- **Stage Registry**: quay.io/foreman (with -stage suffix)
- **Mirror Strategy**: Regional mirrors for performance

### Image Promotion Workflow
```
Development → Stage Images → Validation → Production Images
     ↓              ↓             ↓            ↓
   Build        Test Deploy    QA/Testing   Production
```

## Version Management

### Semantic Versioning Alignment
- **Major Version**: Breaking changes or major feature releases
- **Minor Version**: Feature additions and improvements
- **Patch Version**: Bug fixes and security updates

### Tag Lifecycle Management
- **Latest Tag**: Points to most recent stable release
- **Stable Tags**: Long-term support versions
- **Development Tags**: Active development branches

## Security and Compliance

### Image Scanning Integration
- **Vulnerability Scanning**: Automated security assessment
- **Compliance Checking**: Policy compliance validation
- **Supply Chain Security**: Dependency tracking and validation

### Image Signing Strategy
- **Digital Signatures**: Cryptographic image signing
- **Provenance Tracking**: Build attestation and verification
- **Registry Security**: Secure image distribution

## Integration with Foremanctl

### Container Image Discovery
Foremanctl will automatically discover and use appropriate container images based on:
- **Configuration Parameters**: User-specified component selection
- **Version Requirements**: Foreman version compatibility
- **Feature Requirements**: Required plugin combinations

### Dynamic Image Selection
```yaml
# Example configuration-driven image selection
foreman_variant: "katello"              # Selects Foreman + Katello image
foreman_version: "3.12"                 # Selects foreman-3.12 tag
plugins_enabled:                        # Additional plugin requirements
  - discovery
  - remote_execution
```

### Local Image Management
- **Image Caching**: Local image cache management
- **Update Strategy**: Automated image updates and rollback
- **Offline Deployment**: Support for air-gapped environments

## Future Considerations

### Kubernetes Integration
- **Helm Chart Compatibility**: Container images optimized for Kubernetes
- **Operator Integration**: Custom resource definitions for image management
- **Rolling Updates**: Kubernetes-native update strategies

### Multi-Architecture Support
- **AMD64 Support**: Primary x86_64 architecture
- **ARM64 Support**: Future ARM architecture support
- **Multi-Arch Manifests**: Automatic architecture selection

### Performance Optimization
- **Image Size Reduction**: Minimal container footprint
- **Startup Time**: Fast container initialization
- **Resource Efficiency**: Optimized resource utilization