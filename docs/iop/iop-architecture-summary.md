---
title: iop-architecture-summary
type: note
permalink: infrastructure/iop-architecture-summary
---

# iop-architecture-summary

### Architecture Overview
- **Isolated Networking**: Podman bridge network for secure inter-service communication
- **Event-Driven Messaging**: Kafka message bus for real-time data processing
- **Data Processing Pipeline**: Ingress → Collection (Puptoo/Yuptoo) → Engine → Storage
- **Host Inventory**: PostgreSQL-backed system with Foreign Data Wrapper support
- **Smart Proxy Integration**: Nginx gateway providing standard Smart Proxy API compatibility

### Container Types Overview

The IOP deployment uses four distinct types of containers and services:

- **Persistent Service**: Long-running containers that provide continuous functionality as a systemd service
- **Init Container - Oneshot**: Initialization containers that run once during startup and remain after exit (database migrations, schema upgrades)
- **Scheduled Job - Oneshot with Timer**: Job containers that run periodically based on systemd timers (cleanup tasks, synchronization jobs)
- **Static Assets**: Frontend web assets extracted from containers and served by Apache/Nginx

### Core Infrastructure Services

#### Network Infrastructure
- **`iop-core-network`**: Podman bridge network (`10.130.0.0/24`) providing isolated communication between all IOP services

#### Message Bus and Event Processing
- **`iop-core-kafka`** *[Persistent Service]*: Strimzi Kafka 3.7.1 container in KRaft mode (no Zookeeper)
  - Image: `quay.io/strimzi/kafka:latest-kafka-3.7.1`
  - Port: 9092 (internal)
  - Purpose: Central message bus for inter-service communication

#### Gateway Services
- **`iop-core-gateway`** *[Persistent Service]*: Nginx reverse proxy and Smart Proxy relay
  - Image: `quay.io/iop/gateway`
  - Ports: 24443 (external), 9090 (internal)
  - Purpose: SSL termination, smart-proxy API compatibility, request routing

#### Core Processing Services
- **`iop-core-engine`** *[Persistent Service]*: Central insights processing engine
  - Image: `quay.io/iop/insights-engine:latest`
  - Purpose: Routes console.redhat.com traffic internally, processes insights data

- **`iop-core-ingress`** *[Persistent Service]*: Data ingress service
  - Image: `quay.io/iop/ingress`
  - Ports: 8080 (internal), 3001 (metrics)
  - Purpose: Handles incoming data uploads and validation

#### Data Collection Services
- **`iop-core-puptoo`** *[Persistent Service]*: System data collection and transformation
  - Image: `quay.io/iop/puptoo:latest`
  - Purpose: Processes system information from uploads

- **`iop-core-yuptoo`** *[Persistent Service]*: YUM/DNF package data collection
  - Image: `quay.io/iop/yuptoo:latest`
  - Purpose: Processes package information and repositories

#### Host Inventory System
- **`iop-core-host-inventory-migrate`** *[Init Container - Oneshot]*: Database migration container
  - Image: `quay.io/iop/host-inventory:latest`
  - Purpose: Database schema upgrades and readiness checks
  - Note: Runs once during startup, remains after exit

- **`iop-core-host-inventory`** *[Persistent Service]*: Host inventory message queue service
  - Image: `quay.io/iop/host-inventory:latest`
  - Purpose: Kafka message processing for host inventory updates

- **`iop-core-host-inventory-api`** *[Persistent Service]*: Host inventory REST API
  - Image: `quay.io/iop/host-inventory:latest`
  - Port: 8081
  - Purpose: REST API for host inventory data access

- **`iop-core-host-inventory-cleanup`** *[Scheduled Job - Oneshot with Timer]*: Cleanup job container
  - Image: `quay.io/iop/host-inventory:latest`
  - Purpose: Periodic cleanup of access tags and stale data
  - Note: Runs on timer schedule, not continuously running

- **Host Inventory Frontend** *[Static Assets]*: Static web assets extracted from container
  - Image: `quay.io/iop/host-inventory-frontend:latest`
  - Location: `/var/lib/foreman/public/assets/apps/inventory`

## Vulnerability Services

### Architecture Overview
- **VMAAS Integration**: Vulnerability Metadata and Assessment Service for CVE data
- **Multi-Component Engine**: Distributed vulnerability processing with specialized workers
- **Database Integration**: Foreign Data Wrapper connections to host inventory
- **Katello Sync**: Repository vulnerability data synchronization
- **Event-Driven Processing**: Kafka-based vulnerability evaluation pipeline

### Vulnerability Services

#### VMAAS (Vulnerability Metadata and Assessment Service)
- **`iop-service-vmaas-reposcan`** *[Persistent Service]*: Repository scanning and vulnerability metadata
  - Image: `quay.io/iop/vmaas:latest`
  - Ports: 8000 (public), 10000 (private), 8085 (metrics)
  - Purpose: Scans repositories, syncs CVE data, manages vulnerability metadata

- **`iop-service-vmaas-webapp-go`** *[Persistent Service]*: VMAAS API service
  - Image: `quay.io/iop/vmaas:latest`
  - Port: 8000
  - Purpose: Provides vulnerability assessment API

#### Vulnerability Engine Services
- **`iop-service-vuln-dbupgrade`** *[Init Container - Oneshot]*: Database migration container
  - Image: `quay.io/iop/vulnerability-engine:latest`
  - Purpose: Vulnerability database schema upgrades
  - Note: Runs once during startup, remains after exit

- **`iop-service-vuln-manager`** *[Persistent Service]*: Vulnerability management service
  - Image: `quay.io/iop/vulnerability-engine:latest`
  - Purpose: Central vulnerability management and coordination

- **`iop-service-vuln-taskomatic`** *[Persistent Service]*: Scheduled vulnerability tasks
  - Image: `quay.io/iop/vulnerability-engine:latest`
  - Purpose: Runs periodic tasks (stale systems cleanup, cache management)

- **`iop-service-vuln-grouper`** *[Persistent Service]*: Vulnerability data grouping service
  - Image: `quay.io/iop/vulnerability-engine:latest`
  - Port: 8085 (metrics)
  - Purpose: Groups vulnerability data by various criteria

- **`iop-service-vuln-listener`** *[Persistent Service]*: Kafka event listener
  - Image: `quay.io/iop/vulnerability-engine:latest`
  - Purpose: Listens to inventory events and advisor results

- **`iop-service-vuln-evaluator-recalc`** *[Persistent Service]*: Vulnerability recalculation evaluator
  - Image: `quay.io/iop/vulnerability-engine:latest`
  - Purpose: Processes vulnerability recalculation requests

- **`iop-service-vuln-evaluator-upload`** *[Persistent Service]*: Vulnerability upload evaluator
  - Image: `quay.io/iop/vulnerability-engine:latest`
  - Purpose: Processes new vulnerability upload data

- **`iop-service-vuln-vmaas-sync`** *[Scheduled Job - Oneshot with Timer]*: VMAAS synchronization job
  - Image: `quay.io/iop/vulnerability-engine:latest`
  - Purpose: Periodic synchronization with VMAAS service
  - Note: Runs on timer schedule, not continuously running

#### Vulnerability Frontend
- **Vulnerability Frontend** *[Static Assets]*: Static web assets extracted from container
  - Image: `quay.io/iop/vulnerability-frontend:latest`
  - Location: `/var/lib/foreman/public/assets/apps/vulnerability`

#### Supporting Services
- **CVE Map Downloader** *[Scheduled Job - Oneshot with Timer]*: System service for CVE map file management
  - Service: `iop-cvemap-download.service` (systemd oneshot with timer)
  - Script: `/usr/local/bin/iop-cvemap-download.sh`
  - Purpose: Downloads and manages CVE mapping files for vulnerability scanning
  - Timer: Runs every 24 hours
  - Note: Runs on timer schedule, not continuously running

## Advisor Services

### Architecture Overview
- **Recommendation Engine**: Analyzes system data to provide optimization suggestions
- **API and Background Services**: Separated API layer and background processing
- **Database Integration**: Foreign Data Wrapper connections to host inventory
- **Remediation Integration**: Automated fix suggestions and playbook generation
- **Frontend Integration**: React-based UI components for recommendation display

### Advisor Services

#### Advisor Backend Services
- **`iop-service-advisor-backend-api`** *[Persistent Service]*: Advisor API service
  - Image: `quay.io/iop/advisor-backend:latest`
  - Purpose: Provides advisor recommendations API

- **`iop-service-advisor-backend-service`** *[Persistent Service]*: Advisor background service
  - Image: `quay.io/iop/advisor-backend:latest`
  - Purpose: Processes advisor data and generates recommendations

#### Advisor Frontend
- **Advisor Frontend** *[Static Assets]*: Static web assets extracted from container
  - Image: `quay.io/iop/advisor-frontend:latest`
  - Location: `/var/lib/foreman/public/assets/apps/advisor`

#### Remediations Services
- **`iop-service-remediations-api`** *[Persistent Service]*: Remediations API service
  - Image: `quay.io/iop/remediations:latest`
  - Purpose: Provides automated remediation suggestions and playbooks

## Container Registry and Resource Management

### Service Dependencies

#### Startup Order
1. **Network**: `iop-core-network`
2. **Message Bus**: `iop-core-kafka`
3. **Core Services**: `iop-core-ingress`, `iop-core-puptoo`, `iop-core-yuptoo`
4. **Processing**: `iop-core-engine`
5. **Gateway**: `iop-core-gateway`
6. **Inventory**: Migration → Service → API
7. **Optional Services**: VMAAS → Vulnerability Engine → Advisor → Remediations

#### Inter-Service Communication
- **Internal Network**: All services communicate via `iop-core-network`
- **Kafka Topics**: Event-driven messaging between services
- **HTTP APIs**: REST API calls between related services
- **Database FDW**: Cross-database queries via PostgreSQL Foreign Data Wrappers

### Resource Management

#### Volumes and Storage
- **`iop-core-kafka-data`**: Persistent Kafka data storage
- **`iop-service-vmaas-data`**: Persistent VMAAS vulnerability data
- **PostgreSQL sockets**: Shared via `/var/run/postgresql` volume mounts

#### Secrets Management
- **Database credentials**: Per-service database connection secrets
- **SSL certificates**: Server and client certificates for gateway
- **Configuration files**: Service-specific configuration secrets

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
