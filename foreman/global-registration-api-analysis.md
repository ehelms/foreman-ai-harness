# Foreman Global Registration API Analysis

## Overview

This document provides a comprehensive analysis of the API calls made during Foreman Global Registration, based on log analysis from a complete host registration workflow. The analysis covers the sequence of operations, performance characteristics, backend service interactions, and optimization opportunities.

## Test Environment Configuration

**Important**: This analysis was performed under the following specific conditions:

1. **Manifest Status**: Red Hat subscription manifest imported and active
2. **Repository Configuration**: RHEL 9 BaseOS repository enabled and fully synchronized
3. **Activation Key**: Using activation key named "rhel9" configured for RHEL 9 content
4. **Registration Method**: Foreman Global Registration feature
5. **Host OS**: Red Hat Enterprise Linux 9.6 (x86_64)

These conditions represent a typical production-ready Foreman/Katello environment. Performance characteristics may vary with different configurations, repository sizes, network conditions, or when using different activation keys or content sets.

## Registration Workflow Summary

Global Registration is a multi-phase process that involves:
1. **Initial Registration Script Download** - Host downloads registration script
2. **Subscription Manager Registration** - Host registers with Candlepin via RHSM APIs
3. **Host Registration** - Foreman creates host record and sets build mode
4. **Package Management Setup** - Profile upload and repository configuration
5. **Insights Integration** - Red Hat Insights client registration and data upload
6. **Build Completion** - Host signals successful setup

## Detailed Registration Flow Phases

### Phase 1: Registration Script Download (15:41:19)
**Duration**: ~1 second
**Key Operations**:
- `GET /register?activation_keys=rhel9&download_utility=curl&location_id=2&organization_id=1&update_packages=false`
- **Duration**: 103ms
- **Purpose**: Generate and download the registration script containing all necessary commands

**Performance**: Fast and efficient, well-optimized endpoint.

### Phase 2: Subscription Manager Registration (15:41:22-15:41:28)
**Duration**: ~6 seconds
**Key Operations**:
1. **RHSM Resource Discovery**:
   - `GET /rhsm/` - Discover available RHSM endpoints (11ms)

2. **Consumer Creation** ⚠️ **CRITICAL PATH BOTTLENECK**:
   - `POST /rhsm/consumers?owner=Default_Organization&activation_keys=rhel9`
   - **Duration**: 3,256ms (longest operation in entire flow)
   - **Operations**:
     - Host record creation in Foreman database
     - Network interface (Nic::Managed) creation
     - Content and Subscription facets creation
     - Facts import (193 facts)
     - Candlepin consumer registration
     - UUID generation and assignment

3. **Certificate and Content Management**:
   - Certificate serial retrieval (140ms)
   - Certificate download (249ms)
   - Content access validation (33ms)
   - Content overrides check (25ms)
   - Release information (25ms)

4. **Compliance Status Validation**:
   - Initial compliance checks begin (multiple 29ms calls)

### Phase 3: Host Registration (15:41:28)
**Duration**: ~1 second
**Key Operations**:
- `POST /register` with UUID and host parameters
- **Duration**: 267ms
- **Operations**:
  - Host parameter creation (`host_update_packages=false`)
  - Build mode activation (`build=true`)
  - Build initiation timestamp setting
  - Host ownership assignment

**Performance**: Efficient parameter setup and build mode activation.

### Phase 4: Package Management Setup (15:41:29-15:41:37)
**Duration**: ~8 seconds
**Key Operations**:
1. **Package Profile Upload**:
   - `PUT /rhsm/consumers/{uuid}/profiles`
   - **Duration**: 253ms
   - **Purpose**: Upload installed package inventory to Candlepin

2. **Repository Metadata Synchronization**:
   - Multiple large file downloads from Pulp:
     - `repomd.xml` (4KB)
     - `primary.xml.gz` (74MB) - **Largest download**
     - `filelists.xml.gz` (8MB)
     - `comps.xml` (290KB)
     - `updateinfo.xml.gz` (1.2MB)

**Performance**: Network-bound due to large repository metadata files.

### Phase 5: Insights Integration (15:41:39-15:42:03)
**Duration**: ~24 seconds
**Key Operations**:
1. **Insights Client Initialization**:
   - Multiple `GET /redhat_access/r/insights/v1/branch_info` calls (8 total)
   - Each call: 16-53ms

2. **Module Update Checks**:
   - `GET /redhat_access/r/insights/platform/module-update-router/v1/channel`
   - **Duration**: 1,028ms (external Red Hat API call)

3. **Insights Core Download**:
   - `GET /redhat_access/r/insights/v1/static/release/insights-core.egg`
   - **Duration**: 187ms (1.3MB download)
   - Signature file download (86ms)

4. **System Registration**:
   - `POST /redhat_access/r/insights/v1/systems`
   - **Duration**: 207ms

5. **Data Upload**:
   - `POST /redhat_access/r/insights/uploads/{uuid}`
   - **Duration**: 232ms (compressed system data)

6. **Inventory and Reports**:
   - Platform inventory registration (143-179ms)
   - System reports retrieval (348ms)

**Performance**: External service dependency creates latency; multiple round trips.

### Phase 6: Final Status Updates (15:42:01-15:42:05)
**Duration**: ~4 seconds
**Key Operations**:
1. **Continued Compliance Polling** ⚠️ **PERFORMANCE ISSUE**:
   - Ongoing `GET /rhsm/consumers/{uuid}/compliance` calls
   - **Total**: 13 calls throughout registration
   - Each call: 24-33ms

2. **Facts Update**:
   - `PUT /rhsm/consumers/{uuid}` (facts update)
   - **Duration**: 765ms
   - **Operations**: Import 201 additional facts

3. **Final Validations**:
   - Content access, certificate serials, overrides verification
   - Consumer details retrieval

### Phase 7: Build Completion (15:42:01)
**Duration**: ~1 second
**Key Operations**:
- `GET /unattended/built?token=21fefcb4-e580-4c71-895c-4816741b55fa`
- **Duration**: 159ms
- **Operations**:
  - Set `build=false`
  - Set `installed_at` timestamp
  - Trigger build completion events

**Performance**: Efficient final state transition.

## Registration Sequence Diagram

The following sequence diagram illustrates the complete flow of API calls during Global Registration:

```mermaid
sequenceDiagram
    participant Host as Host System
    participant Apache as Apache/HTTP Server
    participant Foreman as Foreman Rails App
    participant Candlepin as Candlepin
    participant Pulp as Pulp
    participant RHCloud as Red Hat Cloud
    participant Browser as Admin Browser

    Note over Host,RHCloud: Phase 1: Registration Script Download
    Host->>Apache: GET /register?activation_keys=rhel9&... (HTTP/2.0)
    Apache->>Foreman: Forward to Rails app
    Note right of Foreman: 103ms - Generate registration script
    Foreman-->>Apache: Registration script (14833 bytes)
    Apache-->>Host: HTTP 200 - Registration script

    Note over Host,RHCloud: Phase 2: Subscription Manager Registration
    Host->>Apache: GET /rhsm/ (HTTP/1.1)
    Apache->>Foreman: Forward RHSM request
    Foreman->>Candlepin: Forward request
    Candlepin-->>Foreman: RHSM resource list
    Foreman-->>Apache: RHSM endpoints (2344 bytes)
    Apache-->>Host: HTTP 200 - RHSM endpoints

    Host->>Apache: POST /rhsm/consumers?owner=Default_Organization&activation_keys=rhel9 (HTTP/1.1)
    Apache->>Foreman: Forward consumer creation request
    Note right of Foreman: 3,256ms - LONGEST OPERATION
    Foreman->>Candlepin: Create consumer
    Foreman->>Pulp: GET /pulp/api/v3/status/ (2x)
    Foreman->>Foreman: Create host record & facets
    Foreman->>Foreman: Import facts (193 facts)
    Candlepin-->>Foreman: Consumer created
    Foreman-->>Apache: Consumer details + certificates (16131 bytes)
    Apache-->>Host: HTTP 200 - Consumer details

    loop Status and Certificate Checks
        Host->>Apache: GET /rhsm/status (HTTP/1.1)
        Apache->>Foreman: Forward status request
        Foreman->>Candlepin: Forward request
        Candlepin-->>Foreman: Status
        Foreman-->>Apache: Status (669 bytes)
        Apache-->>Host: HTTP 200 - Status (12 total calls)

        Host->>Apache: GET /rhsm/consumers/{uuid}/certificates/serials (HTTP/1.1)
        Apache->>Foreman: Forward certificate request
        Foreman->>Candlepin: Forward request
        Candlepin-->>Foreman: Certificate serials
        Foreman-->>Apache: Serials (105 bytes)
        Apache-->>Host: HTTP 200 - Serials (6 total calls)
    end

    Host->>Apache: GET /rhsm/consumers/{uuid}/certificates?serials=... (HTTP/1.1)
    Apache->>Foreman: Forward certificate download request
    Foreman->>Candlepin: Forward request
    Note right of Candlepin: 249ms
    Candlepin-->>Foreman: Certificates
    Foreman-->>Apache: Certificate data (7373 bytes)
    Apache-->>Host: HTTP 200 - Certificate data

    loop Content Access Validation
        Host->>Apache: GET /rhsm/consumers/{uuid}/accessible_content (HTTP/1.1)
        Apache->>Foreman: Forward content access request
        Foreman->>Candlepin: Forward request
        Candlepin-->>Foreman: Content list / 304 Not Modified
        Foreman-->>Apache: Accessible content (3808 bytes / 304)
        Apache-->>Host: HTTP 200/304 - Accessible content (6 total calls)

        Host->>Apache: GET /rhsm/consumers/{uuid}/content_overrides (HTTP/1.1)
        Apache->>Foreman: Forward overrides request
        Foreman->>Candlepin: Forward request
        Candlepin-->>Foreman: Overrides
        Foreman-->>Apache: Content overrides (2 bytes)
        Apache-->>Host: HTTP 200 - Content overrides
    end

    Host->>Apache: GET /rhsm/consumers/{uuid}/release (HTTP/1.1)
    Apache->>Foreman: Forward release request
    Foreman->>Candlepin: Forward request
    Candlepin-->>Foreman: Release info
    Foreman-->>Apache: Release version (19 bytes)
    Apache-->>Host: HTTP 200 - Release version

    loop Excessive Compliance Polling
        Host->>Apache: GET /rhsm/consumers/{uuid}/compliance (HTTP/1.1)
        Apache->>Foreman: Forward compliance request
        Foreman->>Candlepin: Forward request
        Candlepin-->>Foreman: Compliance status
        Foreman-->>Apache: Compliance data (240 bytes)
        Apache-->>Host: HTTP 200 - Compliance data
        Note over Host,Candlepin: 13 total calls - PERFORMANCE ISSUE
    end

    Note over Host,RHCloud: Phase 3: Host Registration
    Host->>Apache: POST /register (HTTP/2.0)
    Apache->>Foreman: Forward registration request
    Note right of Foreman: 267ms - Set host parameters & build mode
    Foreman->>Foreman: Update host build=true
    Foreman->>Foreman: Set parameters
    Foreman-->>Apache: Registration confirmation (5627 bytes)
    Apache-->>Host: HTTP 200 - Registration confirmation

    Note over Host,RHCloud: Phase 4: Package Management
    Host->>Apache: PUT /rhsm/consumers/{uuid}/profiles (HTTP/1.1)
    Apache->>Foreman: Forward profile upload request
    Note right of Foreman: 253ms - Upload package profiles
    Foreman->>Candlepin: Update profiles
    Candlepin-->>Foreman: Profile updated
    Foreman-->>Apache: Success (16131 bytes)
    Apache-->>Host: HTTP 200 - Profile updated

    Host->>Apache: GET /pulp/content/.../repodata/repomd.xml (HTTP/2.0)
    Apache->>Pulp: Forward to Pulp content server
    Pulp-->>Apache: Repository metadata (4162 bytes)
    Apache-->>Host: HTTP 200 - Repository metadata
    Host->>Apache: GET /pulp/content/.../primary.xml.gz (HTTP/2.0)
    Apache->>Pulp: Forward to Pulp content server
    Pulp-->>Apache: Package data (74MB)
    Apache-->>Host: HTTP 200 - Package data (74MB)
    Host->>Apache: GET /pulp/content/.../filelists.xml.gz (HTTP/2.0)
    Apache->>Pulp: Forward to Pulp content server
    Pulp-->>Apache: File lists (8MB)
    Apache-->>Host: HTTP 200 - File lists (8MB)
    Host->>Apache: GET /pulp/content/.../updateinfo.xml.gz (HTTP/2.0)
    Apache->>Pulp: Forward to Pulp content server
    Pulp-->>Apache: Update info (1.2MB)
    Apache-->>Host: HTTP 200 - Update info

    Note over Host,RHCloud: Phase 5: Insights Integration
    loop Insights Branch Info
        Host->>Apache: GET /redhat_access/r/insights/v1/branch_info (HTTP/1.1)
        Apache->>Foreman: Forward Insights request
        Foreman->>RHCloud: Forward to Red Hat Cloud
        RHCloud-->>Foreman: Branch information
        Foreman-->>Apache: Branch info (1064 bytes)
        Apache-->>Host: HTTP 200 - Branch info (8 total calls)
    end

    Host->>Apache: GET /redhat_access/r/insights/platform/module-update-router/v1/channel (HTTP/1.1)
    Apache->>Foreman: Forward module update request
    Note right of Foreman: 1,028ms - External Red Hat API
    Foreman->>RHCloud: Forward request
    RHCloud-->>Foreman: Module update info
    Foreman-->>Apache: Update channel (18 bytes)
    Apache-->>Host: HTTP 200 - Update channel

    Host->>Apache: GET /redhat_access/r/insights/v1/static/release/insights-core.egg (HTTP/1.1)
    Apache->>Foreman: Forward core download request
    Note right of Foreman: 187ms - Download Insights core
    Foreman->>RHCloud: Forward request
    RHCloud-->>Foreman: Insights core package (1.3MB)
    Foreman-->>Apache: Package data (1316124 bytes)
    Apache-->>Host: HTTP 200 - Package data

    Host->>Apache: GET /redhat_access/r/insights/v1/static/release/insights-core.egg.asc (HTTP/1.1)
    Apache->>Foreman: Forward signature request
    Foreman->>RHCloud: Forward request
    RHCloud-->>Foreman: Signature file
    Foreman-->>Apache: Signature (801 bytes)
    Apache-->>Host: HTTP 200 - Signature

    Host->>Apache: POST /redhat_access/r/insights/v1/systems (HTTP/1.1)
    Apache->>Foreman: Forward system registration
    Note right of Foreman: 207ms - Register with Insights
    Foreman->>RHCloud: Forward system registration
    RHCloud-->>Foreman: Registration response
    Foreman-->>Apache: Registration confirmation (223 bytes)
    Apache-->>Host: HTTP 201 - Registration confirmation

    Host->>Apache: POST /redhat_access/r/insights/uploads/{uuid} (HTTP/1.1)
    Apache->>Foreman: Forward data upload
    Note right of Foreman: 232ms - Upload Insights data
    Foreman->>RHCloud: Forward upload
    RHCloud-->>Foreman: Upload confirmation
    Foreman-->>Apache: Upload success (106 bytes)
    Apache-->>Host: HTTP 201 - Upload success

    Host->>Apache: GET /redhat_access/r/insights/platform/inventory/v1/hosts (HTTP/1.1)
    Apache->>Foreman: Forward inventory request
    Foreman->>RHCloud: Forward request
    RHCloud-->>Foreman: Host inventory data
    Foreman-->>Apache: Inventory response (57/1448 bytes)
    Apache-->>Host: HTTP 200 - Inventory response

    Host->>Apache: GET /redhat_access/r/insights/platform/insights/v1/system/{id}/reports/ (HTTP/1.1)
    Apache->>Foreman: Forward reports request
    Foreman->>RHCloud: Forward request
    RHCloud-->>Foreman: Insights reports
    Foreman-->>Apache: Report data (9941 bytes)
    Apache-->>Host: HTTP 200 - Report data

    Note over Host,RHCloud: Phase 6: Final Status Updates
    loop Final Compliance Checks
        Host->>Apache: GET /rhsm/consumers/{uuid}/compliance (HTTP/1.1)
        Apache->>Foreman: Forward compliance request
        Foreman->>Candlepin: Forward request
        Candlepin-->>Foreman: Compliance status
        Foreman-->>Apache: Final compliance (240 bytes)
        Apache-->>Host: HTTP 200 - Final compliance
    end

    Host->>Apache: PUT /rhsm/consumers/{uuid} (facts update) (HTTP/1.1)
    Apache->>Foreman: Forward facts update
    Note right of Foreman: 765ms - Update facts
    Foreman->>Candlepin: Update consumer facts
    Foreman->>Foreman: Process 201 new facts
    Candlepin-->>Foreman: Facts updated
    Foreman-->>Apache: Update confirmation (41 bytes)
    Apache-->>Host: HTTP 200 - Update confirmation

    Note over Host,RHCloud: Phase 7: Build Completion
    Host->>Apache: GET /unattended/built?token=... (HTTP/1.1)
    Apache->>Foreman: Forward build completion
    Note right of Foreman: 159ms - Mark build complete
    Foreman->>Foreman: Set build=false, installed_at=now
    Foreman-->>Apache: Build completion confirmed
    Apache-->>Host: HTTP 201 - Build completion confirmed

    Note over Host,RHCloud: Background: Browser UI Updates
    Browser->>Apache: GET /notification_recipients (periodic) (HTTP/2.0)
    Apache->>Foreman: Forward notification request
    Foreman-->>Apache: UI notifications (1265 bytes)
    Apache-->>Browser: HTTP 200 - UI notifications (3 calls during process)
```

### Sequence Diagram Summary

| Phase | Duration | Key Operations | Performance Notes |
|-------|----------|----------------|-------------------|
| 1. Script Download | ~1s | GET /register | Fast, efficient |
| 2. RHSM Registration | ~6s | POST /rhsm/consumers | **Longest phase - 3.2s bottleneck** |
| 3. Host Registration | ~1s | POST /register | Quick parameter setup |
| 4. Package Management | ~10s | Profile upload + repo sync | Large file downloads |
| 5. Insights Integration | ~15s | Multiple API calls | External service latency |
| 6. Status Updates | ~5s | Facts update | Moderate processing time |
| 7. Build Completion | ~1s | Mark complete | Final cleanup |

**Total Registration Time: ~45 seconds**

### Critical Path Analysis

The critical path for registration performance is:
1. **Consumer Creation (3,256ms)** - Database operations, facts import, host creation
2. **External API Calls to Red Hat Cloud** - Network latency dependent
3. **Package Repository Synchronization** - Large file transfers
4. **Repeated Compliance Polling** - Unnecessary overhead

## API Call Analysis

### Total Operations
- **Total API Calls**: 67 calls (corrected count from Apache logs)
- **Duration**: ~45 seconds (15:41:19 to 15:42:06)
- **Primary Backend Services**: Candlepin, Pulp, Red Hat Cloud Services

**Note**: This count reflects unique HTTP requests from Apache access logs, avoiding double-counting between Apache and Foreman application logs.

### API Call Frequency Analysis

**Complete List of API Calls (by frequency):**
1. **`GET /rhsm/consumers/{uuid}/compliance`** - **13 calls** (excessive polling for compliance status)
2. **`GET /rhsm/status`** - **12 calls** (server status checks)
3. **`GET /redhat_access/r/insights/v1/branch_info`** - **8 calls** (Insights client checks)
4. **`GET /rhsm/consumers/{uuid}/accessible_content`** - **6 calls** (content access checks)
5. **`GET /rhsm/consumers/{uuid}/certificates/serials`** - **6 calls** (certificate serial checks)
6. **`GET /rhsm/consumers/{uuid}/content_overrides`** - **6 calls** (content override checks)
7. **`GET /pulp/content/.../repodata/repomd.xml`** - **4 calls** (repository metadata)
8. **`GET /pulp/content/.../repodata/primary.xml.gz`** - **4 calls** (package data - 74MB each)
9. **`GET /notification_recipients`** - **3 calls** (UI notifications)
10. **`GET /rhsm/consumers/{uuid}`** - **3 calls** (consumer details)
11. **`POST /rhsm/consumers`** - **1 call** (consumer creation - 3,256ms)
12. **`GET /register`** - **1 call** (registration script download - 103ms)
13. **`GET /rhsm/`** - **1 call** (RHSM resource discovery - 11ms)
14. **`GET /rhsm/consumers/{uuid}/certificates`** - **1 call** (certificate download - 249ms)
15. **`GET /rhsm/consumers/{uuid}/release`** - **1 call** (release information - 25ms)
16. **`POST /register`** - **1 call** (host registration - 267ms)
17. **`PUT /rhsm/consumers/{uuid}/profiles`** - **1 call** (package profile upload - 253ms)
18. **`GET /redhat_access/r/insights/platform/module-update-router/v1/channel`** - **1 call** (1,028ms)
19. **`GET /redhat_access/r/insights/v1/static/release/insights-core.egg`** - **1 call** (187ms, 1.3MB)
20. **`GET /redhat_access/r/insights/v1/static/release/insights-core.egg.asc`** - **1 call** (86ms)
21. **`POST /redhat_access/r/insights/v1/systems`** - **1 call** (system registration - 207ms)
22. **`POST /redhat_access/r/insights/uploads/{uuid}`** - **1 call** (data upload - 232ms)
23. **`GET /redhat_access/r/insights/platform/inventory/v1/hosts`** - **1 call** (inventory - 143ms)
24. **`GET /redhat_access/r/insights/platform/insights/v1/system/{id}/reports/`** - **1 call** (reports - 348ms)
25. **`PUT /rhsm/consumers/{uuid}`** - **1 call** (facts update - 765ms)
26. **`GET /unattended/built`** - **1 call** (build completion - 159ms)

### Performance Analysis

**Longest Running API Calls:**
1. **`POST /rhsm/consumers` (consumer activation)** - **3,256ms** (host creation, facts import, Candlepin registration)
2. **`PUT /rhsm/consumers/{uuid}` (facts update)** - **765ms** (facts import and processing)
3. **`GET /redhat_access/r/insights/platform/module-update-router/v1/channel`** - **1,028ms** (external Red Hat API call)
4. **`POST /register` (host registration)** - **267ms** (host parameter setup)
5. **`PUT /rhsm/consumers/{uuid}/profiles`** - **253ms** (package profile upload)

### Backend Service Distribution

**Candlepin Backend Calls (45 calls - 67% of total):**
- Consumer creation and management: 1 call
- Compliance status checking: 13 calls (major contributor)
- Status checks: 12 calls
- Content access validation: 6 calls
- Certificate management: 7 calls (serials + download)
- Content overrides: 6 calls
- Consumer details: 3 calls
- Facts updates: 1 call
- Release information: 1 call
- RHSM resource discovery: 1 call

**Pulp Backend Calls (8 calls - 12% of total):**
- **Direct content downloads**: `/pulp/content/` for repository metadata
- **Large transfers**: repomd.xml (4 calls), primary.xml.gz (4 calls, 74MB each)
- **No status calls**: Pulp content accessed directly, not via API

**Red Hat Cloud Services (13 calls - 19% of total):**
- Insights API endpoints: 8 calls to `/redhat_access/r/insights/v1/branch_info`
- Module update router: 1 call
- File downloads: 2 calls (core package + signature)
- System registration: 1 call
- Data uploads: 1 call
- Platform inventory: 1 call
- Reports query: 1 call

**Foreman APIs (6 calls - 9% of total):**
- Registration endpoints: `/register` (GET and POST) - 2 calls
- Notifications: `/notification_recipients` - 3 calls
- Build completion: `/unattended/built` - 1 call

## Performance Bottlenecks Summary

Based on the sequence diagram and log analysis, the primary performance issues are:

1. **Excessive API Call Frequency**:
   - Compliance checks: 13 calls (24-33ms each)
   - Status checks: 12 calls (20-29ms each)
   - Content access: 6 calls (some cached with 304 responses)

2. **Long-running Operations**:
   - Consumer creation: 3,256ms (critical path bottleneck)
   - Facts updates: 765ms
   - External Red Hat APIs: 1,000ms+

3. **Large Data Transfers**:
   - Package repository data: 74MB+ downloads from Pulp
   - Insights data uploads: Variable size transfers

## Optimization Opportunities

### Critical Performance Issues

#### 1. Consumer Creation Bottleneck (3,256ms)
**Current State**: Single synchronous operation handling:
- Database record creation
- Facts processing (193 facts)
- Candlepin registration
- Facet creation

**Recommendations**:
- **Implement async facts processing**: Move fact import to background job
- **Optimize database transactions**: Use bulk inserts for facts
- **Parallelize operations**: Create host record and Candlepin consumer concurrently
- **Add operation caching**: Cache commonly used facts during registration
- **Database indexing**: Ensure optimal indexes on fact tables

#### 2. Excessive Compliance Polling (13 calls)
**Current State**: Subscription-manager polls compliance status repeatedly

**Recommendations**:
- **Implement exponential backoff**: Start with 1s, increase to 30s intervals
- **Add compliance state caching**: Cache compliance results for 60s
- **Optimize Candlepin queries**: Index compliance-related tables
- **Batch compliance checks**: Combine multiple compliance validations
- **Client-side intelligence**: Only check compliance when certificates change

#### 3. Redundant Status Checks (12 calls)
**Current State**: Every operation validates server status

**Recommendations**:
- **Session-based status caching**: Validate status once per client session
- **Add status headers**: Include server status in API response headers
- **Implement health check endpoint**: Dedicated lightweight status endpoint
- **Client-side caching**: Cache status for 5-10 minutes on client
