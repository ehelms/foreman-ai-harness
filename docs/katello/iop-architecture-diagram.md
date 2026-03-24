# IoP (Insights-on-Prem) Architecture Diagram

This diagram illustrates how RHEL hosts communicate with Satellite Server's Foreman component, which then interacts with IoP services through the iop-gateway for vulnerability management and package analysis.

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

    subgraph "IoP Gateway"
        IOP_GATEWAY["iop-gateway<br/>- API proxy<br/>- Request routing<br/>- Authentication"]
    end

    subgraph "IoP Services"
        IOP_VULNERABILITY["iop-vulnerability<br/>- Vulnerability analysis<br/>- CVE assessment<br/>- Risk scoring"]
        IOP_VMAAS["iop-vmaas<br/>- Package analysis<br/>- Errata mapping<br/>- Update recommendations"]
    end

    RHEL_HOST --> FOREMAN_CORE
    PKG_PROFILE_SM --> FOREMAN_CORE
    ENABLED_REPOS --> FOREMAN_CORE
    PKG_PROFILE_IC --> FOREMAN_CORE

    FOREMAN_CORE --> IOP_GATEWAY
    IOP_GATEWAY --> IOP_VULNERABILITY
    IOP_GATEWAY --> IOP_VMAAS

    classDef host fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef hostComponent fill:#fff8e1,stroke:#f9a825,stroke-width:1px
    classDef satellite fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px
    classDef foreman fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    classDef gateway fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef iopService fill:#fce4ec,stroke:#c2185b,stroke-width:2px

    class RHEL_HOST host
    class PKG_PROFILE_SM,ENABLED_REPOS,PKG_PROFILE_IC hostComponent
    class FOREMAN_CORE foreman
    class IOP_GATEWAY gateway
    class IOP_VULNERABILITY,IOP_VMAAS iopService
```

## Key Components

### RHEL Host
- **Host System**: Production RHEL server running various applications
- **subscription-manager**: Manages subscriptions and repository access
  - **Package Profile**: Installed packages reported to Satellite
  - **Enabled Repositories**: Active repository subscriptions
- **insights-client**: Red Hat Insights agent for vulnerability assessment
  - **Package Profile**: Package inventory sent to IoP services

### Satellite Server
- **Foreman Core**: Central management component for host lifecycle management
- Orchestrates communication between hosts and IoP services
- Manages inventory tracking and policy enforcement

### IoP Gateway
- **iop-gateway**: API gateway and proxy service
- Routes requests between Foreman and IoP backend services
- Handles authentication and request transformation

### IoP Services
- **iop-vulnerability**: Vulnerability analysis service
  - Performs CVE assessment and risk scoring
  - Analyzes security implications of installed packages
- **iop-vmaas**: Package analysis service (VMware as a Service)
  - Maps packages to available errata
  - Provides update recommendations and compatibility analysis

## Workflow
1. **Data Collection**: Both subscription-manager and insights-client collect package profiles from RHEL hosts
2. **Foreman Integration**: Package data flows to Foreman for centralized inventory management
3. **IoP Communication**: Foreman sends package profiles to IoP services via iop-gateway
4. **Vulnerability Analysis**: iop-vulnerability performs security assessment of installed packages
5. **Package Analysis**: iop-vmaas analyzes packages for available updates and errata
6. **Response Aggregation**: Results flow back through iop-gateway to Foreman for host management decisions