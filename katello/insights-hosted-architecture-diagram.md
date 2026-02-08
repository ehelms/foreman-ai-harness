# Red Hat Insights Hosted Architecture Diagram

This diagram illustrates how RHEL hosts communicate with Satellite Server's Foreman component, which then interacts with hosted Red Hat Insights services in the cloud for vulnerability management and package analysis.

```mermaid
graph TD
    subgraph "RHEL Host"
        RHEL_HOST["RHEL Host<br/>rhel9-web01.example.com<br/>IP: 192.168.1.100"]
        subgraph "subscription-manager"
            PKG_PROFILE_SM["Package Profile<br/>- httpd-2.4.57<br/>- kernel-5.14.0<br/>- openssl-3.0.7"]
            ENABLED_REPOS["Enabled Repositories<br/>- RHEL-BaseOS-RPMs<br/>- RHEL-AppStream-RPMs<br/>- RHEL-BaseOS-Debug"]
        end
        subgraph "insights-client"
            PKG_PROFILE_IC["Package Profile<br/>- httpd-2.4.57<br/>- kernel-5.14.0<br/>- openssl-3.0.7"]
        end
    end

    subgraph "Satellite Server"
        subgraph "Foreman"
            FOREMAN_CORE["Foreman Core<br/>- Host management<br/>- Inventory tracking<br/>- Lifecycle orchestration"]
        end
    end

    subgraph "Red Hat Insights (Hosted)"
        INSIGHTS_VULNERABILITY["Insights Vulnerability Service<br/>- Cloud-based CVE analysis<br/>- Security risk assessment<br/>- Vulnerability scoring"]
        INSIGHTS_VMAAS["Insights VMaaS Service<br/>- Hosted package analysis<br/>- Cloud errata mapping<br/>- Update recommendations"]
    end

    RHEL_HOST --> FOREMAN_CORE
    PKG_PROFILE_SM --> FOREMAN_CORE
    ENABLED_REPOS --> FOREMAN_CORE
    PKG_PROFILE_IC --> FOREMAN_CORE

    FOREMAN_CORE --> INSIGHTS_VULNERABILITY
    FOREMAN_CORE --> INSIGHTS_VMAAS

    classDef host fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef hostComponent fill:#fff8e1,stroke:#f9a825,stroke-width:1px
    classDef satellite fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px
    classDef foreman fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    classDef cloudService fill:#e8eaf6,stroke:#3f51b5,stroke-width:2px

    class RHEL_HOST host
    class PKG_PROFILE_SM,ENABLED_REPOS,PKG_PROFILE_IC hostComponent
    class FOREMAN_CORE foreman
    class INSIGHTS_VULNERABILITY,INSIGHTS_VMAAS cloudService
```

## Key Components

### RHEL Host
- **Host System**: Production RHEL server running various applications
- **subscription-manager**: Manages subscriptions and repository access
  - **Package Profile**: Installed packages reported to Satellite
  - **Enabled Repositories**: Active repository subscriptions
- **insights-client**: Red Hat Insights agent for cloud-based vulnerability assessment
  - **Package Profile**: Package inventory sent to hosted Insights services

### Satellite Server
- **Foreman Core**: Central management component for host lifecycle management
- Orchestrates communication between hosts and hosted Insights services
- Manages inventory tracking and policy enforcement

### Red Hat Insights (Hosted Cloud Services)
- **Insights Vulnerability Service**: Cloud-hosted vulnerability analysis
  - Performs comprehensive CVE analysis using Red Hat's security database
  - Provides security risk assessment and vulnerability scoring
  - Leverages cloud-scale threat intelligence and analysis capabilities
- **Insights VMaaS Service**: Cloud-hosted package analysis service
  - Maps installed packages to available errata and updates
  - Provides update recommendations and compatibility analysis
  - Maintains comprehensive package and vulnerability databases

## Workflow
1. **Data Collection**: Both subscription-manager and insights-client collect package profiles from RHEL hosts
2. **Foreman Integration**: Package data flows to Foreman for centralized inventory management
3. **Cloud Communication**: Foreman sends package profiles directly to hosted Insights services
4. **Cloud Vulnerability Analysis**: Insights Vulnerability Service performs comprehensive security assessment
5. **Cloud Package Analysis**: Insights VMaaS Service analyzes packages for available updates and errata
6. **Response Integration**: Results flow back to Foreman for host management decisions and policy enforcement

## Benefits of Hosted Architecture
- **Always Updated**: Cloud services maintain the latest vulnerability and package databases
- **Scalable Analysis**: Leverages Red Hat's cloud infrastructure for comprehensive analysis
- **Reduced Infrastructure**: No need to maintain on-premises IoP services
- **Expert Maintenance**: Cloud services are maintained and updated by Red Hat security experts