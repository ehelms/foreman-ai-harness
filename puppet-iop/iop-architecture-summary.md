---
title: iop-architecture-summary
type: note
permalink: infrastructure/iop-architecture-summary
---

# iop-architecture-summary

## Overview
IOP is a containerized microservices architecture for comprehensive infrastructure monitoring, vulnerability assessment, and advisory services for Red Hat Enterprise Linux systems.

## Core Infrastructure Components

### Network & Gateway
- **Core Network**: Isolated Podman networking for inter-service communication
- **Core Gateway**: Nginx reverse proxy on port 24443 with SSL termination and Smart Proxy relay for Foreman integration

### Message Bus & Processing  
- **Core Kafka**: Strimzi Kafka 3.7.1 in KRaft mode (no Zookeeper), persistent storage, central message bus
- **Core Engine**: Central insights processing engine, routes console.redhat.com traffic internally

### Data Collection
- **Core Puptoo**: System data collection and transformation
- **Core Yuptoo**: YUM/DNF package data collection

## Host Inventory System
- **PostgreSQL-backed** with Foreign Data Wrapper (FDW)
- **Three-container deployment**: Migration, Message Queue, API service (port 8081)
- **Inventory views** with insights_id mapping
- **RBAC bypass** for internal communication
- **Frontend**: Static web assets via Apache

## Service Layer (Optional)

### Vulnerability Services
- **VMAAS**: Vulnerability metadata and assessment
  - Reposcan service, Webapp-Go API
  - Katello integration, CVE mapping
- **Vulnerability Engine**: Multi-component service
  - Manager, Taskomatic, Grouper, Listener
  - Evaluator (Upload/Recalc), VMAAS Sync

### Advisory Services  
- **Advisor Engine**: System recommendations
- **Advisor Frontend**: UI components
- **Remediations**: Automated fix suggestions

## Database Architecture

### Multi-Database Design
- Each service maintains its own PostgreSQL database
- Foreign Data Wrappers (FDW) enable cross-database queries
- Host inventory serves as central data hub
- Vulnerability and VMAAS databases link to inventory data

### Database Names & Purpose
- **`inventory_db`**: Host inventory and system data
  - `inventory.hosts` view with insights_id mapping
  - Central FDW hub for cross-database queries
  - RBAC bypass for internal communication
- **`vulnerability_db`**: Vulnerability assessments and metadata
  - Links to inventory_db via FDW
  - Stores vulnerability analysis results
- **`vmaas_db`**: Vulnerability metadata and CVE information
  - CVE mapping and metadata management
  - Repository scanning data
- **`advisor_db`**: System recommendations and insights
  - Advisor engine analysis results
  - System optimization suggestions
- **`remediations_db`**: Automated fix suggestions and remediation data
  - Remediation playbooks and scripts
  - Fix tracking and execution history

### Database Features
- **Foreign Data Wrappers (FDW)**: Cross-service data sharing via `postgres_fdw` extension
- **Persistent storage**: All databases use persistent volumes
- **Schema management**: Migration containers handle upgrades
- **Integration**: PostgreSQL-backed with containerized deployment
- **FDW Implementation**: Automated foreign server creation, user mappings, and view definitions
- **Cross-database access**: Remote `inventory.hosts` table accessible through local schemas

## Security & Integration

### Certificate Management
- **Integration with puppet-certs module** (≥21.0.0) via `certs::iop` class
- **Separate client/server certificate hierarchies** for gateway authentication
- **Secrets management** through Podman secrets with proper file modes (0440)
- **Certificate mounting**: Server certs for SSL termination, client certs for smart-proxy relay
- **Ownership management**: All certificates owned by nginx user (uid=998, gid=998)

### Foreman Integration
- **Smart Proxy registration** (`register_as_smartproxy`)
- **OAuth authentication** with auto-generated consumer key/secret
- **SSL certificate validation** and mutual TLS
- **REST API integration** for host data

## Container Orchestration
- **Podman Quadlet**: Systemd-native container management via puppet-podman module
- **Service dependencies** and ordering through systemd units
- **Volume and secret mounting** with proper file permissions and ownership
- **Container images**: All use quay.io/iop/* registry (configurable versions)
- **Network isolation**: Services communicate via `iop-core-network` bridge network
- **Port publishing**: Gateway exposed on 127.0.0.1:24443 (external) and port 9090 (internal)

## Communication Architecture

### Smart Proxy Registration (One-time Setup)
- IOP registers as Smart Proxy with Foreman at `https://localhost:24443`
- **Follows standard puppet-foreman_proxy registration pattern**:
  - **OAuth credentials**: Used only during initial registration via foreman_smartproxy resource
  - **Post-registration**: All communication uses SSL client certificates (mutual TLS)
  - **Standard smart-proxy protocol**: Same registration flow as traditional smart-proxy deployments
- Gateway acts as unified interface to Foreman, presenting standard smart-proxy API

### Ongoing Communication Flow
- **Primary authentication**: SSL client certificates (mutual TLS)
- **No OAuth storage**: OAuth credentials not maintained after registration (standard pattern)
- **Standard Smart Proxy protocol**: Foreman treats IOP as regular Smart Proxy
- **Certificate-based**: All operational communication uses SSL cert hierarchy
- **Gateway facade**: Nginx gateway implements standard smart-proxy API endpoints, routing to internal microservices

### Data Exchange Points
- **Host Inventory**: REST API via port 8081
- **VMAAS Integration**: Katello sync via `http://iop-core-gateway:9090`
- **Event-driven**: Kafka topics for inter-service messaging

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                FOREMAN SERVER                                   │
│                          (foreman_base_url)                                     │
└─────────────────────┬───────────────────────────────────────────────────────────┘
                      │
                      │ OAuth + SSL Certs
                      │ Smart Proxy Registration
                      │
┌─────────────────────▼───────────────────────────────────────────────────────────┐
│                           IOP INFRASTRUCTURE                                    │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                     IOP GATEWAY (nginx)                                 │   │
│  │                    Port 24443 (External)                               │   │
│  │                   Port 9090 (Internal)                                 │   │
│  │                                                                         │   │
│  │  • Smart Proxy Relay (/etc/nginx/smart-proxy-relay/)                  │   │
│  │  • SSL Termination (Server/Client Certs)                              │   │
│  │  • Reverse Proxy to Internal Services                                  │   │
│  └─────────────────────┬───────────────────────────────────────────────────┘   │
│                        │                                                        │
│                        │ iop-core-network                                       │
│                        │                                                        │
│  ┌─────────────────────▼───────────────────────────────────────────────────┐   │
│  │                    CORE SERVICES                                        │   │
│  │                                                                         │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │   │
│  │  │    KAFKA    │  │   ENGINE    │  │   PUPTOO    │  │   YUPTOO    │    │   │
│  │  │   (9092)    │  │             │  │             │  │             │    │   │
│  │  │             │  │ Insights    │  │ System Data │  │ Package     │    │   │
│  │  │ Event Bus   │  │ Processing  │  │ Collection  │  │ Data        │    │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                   HOST INVENTORY SYSTEM                                 │   │
│  │                                                                         │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                     │   │
│  │  │ HBI-MIGRATE │  │ HBI-SERVICE │  │  HBI-API    │                     │   │
│  │  │             │  │             │  │   (8081)    │                     │   │
│  │  │ DB Schema   │  │ Kafka MQ    │  │ REST API    │                     │   │
│  │  │ Upgrades    │  │ Processing  │  │ External    │                     │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘                     │   │
│  │                         │                                               │   │
│  │  ┌─────────────────────▼─────────────────────────────────────────────┐ │   │
│  │  │              POSTGRESQL (inventory_db)                            │ │   │
│  │  │  • inventory.hosts view (insights_id mapping)                     │ │   │
│  │  │  • Foreign Data Wrapper (FDW) hub                                 │ │   │
│  │  └─────────────────────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                 VULNERABILITY SERVICES (Optional)                       │   │
│  │                                                                         │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │   │
│  │  │    VMAAS    │  │ VULN-ENGINE │  │ VULN-EVAL   │  │ VULN-LISTEN │    │   │
│  │  │             │  │             │  │ Upload/     │  │             │    │   │
│  │  │ Reposcan    │  │ Manager     │  │ Recalc      │  │ Kafka       │    │   │
│  │  │ Webapp-Go   │  │ Taskomatic  │  │             │  │ Events      │    │   │
│  │  │   (8000)    │  │ Grouper     │  │             │  │             │    │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │   │
│  │         │                 │                                             │   │
│  │  ┌──────▼──────┐  ┌───────▼─────────────────────────────────────────┐  │   │
│  │  │ vmaas_db    │  │              vulnerability_db                   │  │   │
│  │  │             │  │                                                 │  │   │
│  │  │ CVE/Meta    │  │              FDW → inventory_db                 │  │   │
│  │  └─────────────┘  └─────────────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                   ADVISOR SERVICES (Optional)                           │   │
│  │                                                                         │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                     │   │
│  │  │   ADVISOR   │  │  ADVISOR    │  │ REMEDIATIONS│                     │   │
│  │  │   ENGINE    │  │  FRONTEND   │  │             │                     │   │
│  │  │             │  │             │  │ Auto-Fix    │                     │   │
│  │  │ Recommendations│ UI Assets   │  │ Suggestions │                     │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘                     │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────┘

DATA FLOW:
══════════

Registration Phase (One-time):
Foreman ══► OAuth (temporary) ══► IOP Gateway
   │                                    ▲
   │                                    │
   └── Smart Proxy Registration ────────┘

Operational Phase (Ongoing):
Foreman ══► SSL Client Certs ══► IOP Gateway ══► Internal Services
   │                                        ▲
   │                                        │
   └── Standard Smart Proxy Protocol ──────┘

VMAAS ══► Katello URL: http://iop-core-gateway:9090
         (Repository data sync)
```

### Key Integration Points
- **Smart Proxy Registration**: `foreman_smartproxy` resource manages OAuth and SSL setup
- **OAuth Credentials**: Auto-generated consumer key/secret for secure API access
- **SSL Certificates**: Mutual TLS using puppet-certs module integration
- **FDW Database Links**: Cross-service data sharing via PostgreSQL Foreign Data Wrappers
- **Kafka Topics**: Event-driven communication for real-time data processing
- **Container Network**: `iop-core-network` provides service isolation and discovery

## Puppet Module Implementation

### Module Structure (`theforeman-iop`)
The IOP deployment is managed by the `puppet-iop` module which provides:

#### Core Components
- **`iop::init`**: Main class orchestrating all IOP services with database configuration
- **`iop::core_*`**: Core infrastructure services (network, kafka, gateway, etc.)
- **`iop::service_*`**: Optional service layers (vulnerability, advisor, remediations)
- **`iop::postgresql_fdw`**: Automated Foreign Data Wrapper configuration

#### Key Implementation Features
- **Modular service deployment**: Each service can be enabled/disabled independently
- **Database abstraction**: Unified database configuration across all services
- **Secret management**: Automated generation and secure storage of credentials
- **Smart proxy integration**: Built-in `foreman_smartproxy` resource for registration
- **Certificate integration**: Seamless integration with `puppet-certs` module

#### Configuration Parameters
- **Database settings**: Centralized database host, port, and credentials for all services
- **Service toggles**: Individual `ensure` parameters for each component
- **Smart proxy options**: Configurable Foreman base URL and registration settings
- **Container images**: Configurable container registry and image versions

#### Dependencies
- **puppet-podman**: Container orchestration via Podman Quadlet
- **puppet-certs**: SSL certificate management for IOP services
- **puppet-postgresql**: Database server and Foreign Data Wrapper setup
- **extlib**: Random password generation and data caching

## Key Features
- **Event-driven communication** via Kafka topics
- **Service isolation** through container networking
- **Scalable microservices** architecture
- **Seamless Foreman/Satellite integration**
- **Comprehensive security** with mutual TLS and OAuth
- **Cross-database queries** via FDW for data consistency
- **Declarative deployment** via Puppet manifests with idempotent configuration