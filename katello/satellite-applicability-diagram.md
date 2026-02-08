# Satellite Server Applicability Calculator Diagram

This diagram illustrates how RHEL hosts communicate with Satellite Server's Foreman component to calculate package applicability.

```mermaid
graph TD
    subgraph "RHEL Host"
        RHEL_HOST["RHEL Host<br/>rhel9-web01.example.com<br/>IP: 192.168.1.100"]
        subgraph "subscription-manager"
            PKG_PROFILE["Package Profile<br/>- httpd-2.4.57<br/>- kernel-5.14.0<br/>- openssl-3.0.7"]
            ENABLED_REPOS["Enabled Repositories<br/>- RHEL-BaseOS-RPMs<br/>- RHEL-AppStream-RPMs<br/>- RHEL-BaseOS-Debug"]
        end
    end

    subgraph "Satellite Server"
        subgraph "Foreman"
            INVENTORY["Inventory<br/>- Stores host data<br/>- Tracks package profiles<br/>- Manages repository assignments"]
            APPLICABILITY_CALC["Applicability Calculator<br/>1. Calculates applicable errata from package profile<br/>2. Calculates installable errata from package profile and enabled repositories"]
        end
    end

    RHEL_HOST --> APPLICABILITY_CALC
    PKG_PROFILE --> INVENTORY
    ENABLED_REPOS --> INVENTORY
    INVENTORY --> APPLICABILITY_CALC

    classDef host fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef hostComponent fill:#fff8e1,stroke:#f9a825,stroke-width:1px
    classDef satellite fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px
    classDef foreman fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    classDef inventory fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef calculator fill:#fce4ec,stroke:#c2185b,stroke-width:2px

    class RHEL_HOST host
    class PKG_PROFILE,ENABLED_REPOS hostComponent
    class INVENTORY inventory
    class APPLICABILITY_CALC calculator
```

## Key Components

### RHEL Host
- **Host System**: Production RHEL server running various applications
- **Package Profile**: Current installed packages reported to Satellite for tracking
- **Enabled Repositories**: Active repository subscriptions providing access to content

### Satellite Server
- **Central management server** running Red Hat Satellite
- Contains Foreman for host lifecycle management and inventory tracking

### Foreman Inventory
- **Host Data Storage**: Centralized repository of host information
- **Package Profile Tracking**: Maintains current package installations for each host
- **Repository Management**: Tracks which repositories are enabled for each host

### Foreman Applicability Calculator
- **Package Analysis**: Compares installed packages with available updates
- **Security Assessment**: Identifies security patches and critical updates
- **Compliance Tracking**: Monitors host compliance with defined policies
- **Update Planning**: Calculates which packages need updates or patches

## Workflow
1. **Host Registration**: RHEL host registers with Satellite Server
2. **Data Collection**: Package profiles and enabled repositories are sent to Foreman Inventory
3. **Inventory Storage**: Foreman Inventory stores and manages host data centrally
4. **Applicability Analysis**: Inventory data feeds into Applicability Calculator
5. **Update Calculation**: Calculator determines applicable updates and security patches
6. **Compliance Assessment**: System tracks compliance status and generates reports