# Content View Lifecycle Environment Diagram

This diagram illustrates how content views work with lifecycle environments in Katello, showing versions in Library and Production environments with a RHEL host consuming content.

```mermaid
graph TD
    CV[Content View: RHEL-BaseOS]

    subgraph "Library Environment"
        CV_V2[Content View Version 2.0<br/>- RHEL 9.4 Packages<br/>- Critical Patches<br/>- Published: 2024-02-01]
    end

    subgraph "Production Environment"
        CV_V1[Content View Version 1.0<br/>- RHEL 9.3 Packages<br/>- Security Updates<br/>- Promoted: 2024-01-15]
    end

    subgraph "RHEL Host"
        RHEL_HOST[RHEL Host<br/>rhel9-web01.example.com<br/>IP: 192.168.1.100]
        PKG_PROFILE[Package Profile<br/>- httpd-2.4.57<br/>- kernel-5.14.0<br/>- openssl-3.0.7]
        ENABLED_REPOS[Enabled Repositories<br/>- RHEL-BaseOS-RPMs<br/>- RHEL-AppStream-RPMs<br/>- RHEL-BaseOS-Debug]
    end

    CV --> CV_V2
    CV_V2 -->|Promote| CV_V1
    RHEL_HOST --> CV_V1

    classDef contentView fill:#e1f5fe,stroke:#0288d1,stroke-width:2px
    classDef environment fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef version fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px
    classDef host fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef hostComponent fill:#fff8e1,stroke:#f9a825,stroke-width:1px

    class CV contentView
    class CV_V1,CV_V2 version
    class RHEL_HOST host
    class PKG_PROFILE,ENABLED_REPOS hostComponent
```

## Key Concepts

### Content View
- **RHEL-BaseOS**: A content view containing base RHEL packages and updates
- Serves as a template for creating consistent package sets across environments

### Lifecycle Environments
- **Library**: Default environment where new content is published and tested
- **Production**: Stable environment running previously tested and promoted content

### Content View Versions
- **Version 1.0**: Stable version in Production with RHEL 9.3 packages
- **Version 2.0**: Newer version in Library with RHEL 9.4 packages, ready for testing

### Host Registration
- **RHEL Host**: Production server consuming content from Production environment
- **Package Profile**: Current installed packages reported back to Katello for tracking
- **Enabled Repositories**: Active repository subscriptions providing access to content
- Receives packages and updates from Content View Version 1.0 (stable/tested)
- Uses subscription-manager to connect to Katello for content access

## Workflow
1. New content is published to **Library** as Version 2.0
2. Content is tested and validated in Library environment
3. Once validated, Version 2.0 will be **promoted** to Production (replacing Version 1.0)
4. Production hosts currently consume stable content from Version 1.0
5. Hosts receive consistent, tested package sets through the content view system
