---
title: container-deployment-patterns
type: note
permalink: installer/container-deployment-patterns
---

# Container Deployment Patterns for Foreman

## Podman Quadlets Integration

### Quadlet Overview
Podman quadlets provide systemd-native container management, enabling containers to be managed as standard systemd services.

### Service Definition Pattern
```ini
# Example quadlet file: foreman-web.container
[Unit]
Description=Foreman Web Application
After=foreman-db.service
Requires=foreman-db.service

[Container]
Image=foreman:latest
PublishPort=443:443
Volume=foreman-config:/etc/foreman:Z
Secret=foreman-database-yml,type=mount,target=/etc/foreman/database.yml
Secret=foreman-secret-key,type=env,target=SECRET_KEY_BASE

[Service]
Restart=always
TimeoutStartSec=300

[Install]
WantedBy=multi-user.target
```

### Service Dependencies
```
foreman-db.service
├── foreman-web.service
├── foreman-worker.service
└── foreman-proxy.service
```

## Secret Management Patterns

### Configuration File Secrets
```bash
# Database configuration
podman secret create foreman-database-yml /tmp/database.yml

# Application configuration
podman secret create foreman-settings-yml /tmp/settings.yml

# Certificate files
podman secret create foreman-ssl-cert /etc/ssl/certs/foreman.crt
podman secret create foreman-ssl-key /etc/ssl/private/foreman.key
```

### Environment Variable Secrets
```bash
# Database credentials
podman secret create foreman-db-password -

# API tokens
podman secret create foreman-admin-token -

# Encryption keys
podman secret create foreman-secret-key -
```

### Naming Convention Implementation
```bash
# Pattern: <service>-<type>-<identifier>
foreman-config-database-yml     # Config files
foreman-secret-admin-password   # Secret strings
katello-config-candlepin-conf   # Service-specific configs
proxy-cert-ssl-crt             # Certificate files
```

## Container Architecture Patterns

### Multi-Container Service Design
```yaml
# Service breakdown
services:
  database:
    image: postgresql:13
    secrets:
      - postgres-password
    volumes:
      - postgres-data:/var/lib/postgresql/data

  web:
    image: foreman:latest
    depends_on:
      - database
    secrets:
      - foreman-database-yml
      - foreman-secret-key
    ports:
      - "443:443"

  worker:
    image: foreman:latest
    command: ["bundle", "exec", "rake", "jobs:work"]
    depends_on:
      - database
    secrets:
      - foreman-database-yml

  proxy:
    image: foreman-proxy:latest
    ports:
      - "8443:8443"
    secrets:
      - proxy-settings-yml
```

### Volume Management Patterns
```bash
# Named volumes for persistent data
podman volume create postgres-data
podman volume create foreman-logs
podman volume create pulp-content

# Configuration volumes
podman volume create foreman-config
podman volume create katello-config
```

## Ansible Integration Patterns

### Playbook Structure
```yaml
# deploy.yml
- name: Deploy Foreman Container Stack
  hosts: foreman_servers
  become: yes
  roles:
    - role: container_runtime
    - role: foreman_secrets
    - role: foreman_database
    - role: foreman_web
    - role: katello_services
```

### Role-Based Configuration
```yaml
# roles/foreman_web/tasks/main.yml
- name: Create Foreman configuration secret
  containers.podman.podman_secret:
    name: foreman-database-yml
    data: "{{ foreman_database_config | to_nice_yaml }}"
    force: true

- name: Deploy Foreman web quadlet
  template:
    src: foreman-web.container.j2
    dest: /etc/containers/systemd/foreman-web.container
  notify: reload systemd

- name: Enable Foreman web service
  systemd:
    name: foreman-web
    enabled: yes
    state: started
    daemon_reload: yes
```

### Template Generation
```jinja2
# templates/foreman-web.container.j2
[Unit]
Description=Foreman Web Application
After={{ foreman_dependencies | join(' ') }}
Requires={{ foreman_dependencies | join(' ') }}

[Container]
Image={{ foreman_image }}:{{ foreman_version }}
PublishPort={{ foreman_port }}:443
{% for volume in foreman_volumes %}
Volume={{ volume }}
{% endfor %}
{% for secret in foreman_secrets %}
Secret={{ secret.name }},type={{ secret.type }},target={{ secret.target }}
{% endfor %}

[Service]
Restart=always
TimeoutStartSec={{ foreman_startup_timeout }}

[Install]
WantedBy=multi-user.target
```

## Development Workflow Patterns

### Environment Setup
```bash
# Development environment initialization
./setup-environment
├── Install Ansible dependencies
├── Configure Vagrant environment
├── Setup container registry access
└── Initialize configuration templates
```

### VM Management
```bash
# VM lifecycle management
./forge vms start    # Create and start VMs
./forge vms stop     # Stop VMs
./forge vms destroy  # Clean up VMs
./forge vms status   # Check VM status
```

### Deployment Process
```bash
# Deployment workflow
./foremanctl deploy
├── Validate configuration
├── Create secrets
├── Deploy quadlet files
├── Start services
└── Run health checks
```

### Testing Integration
```bash
# Automated testing
./forge test
├── Service connectivity tests
├── API endpoint validation
├── Web interface checks
└── Integration test suite
```

## Network Configuration Patterns

### Container Networking
```bash
# Create custom network for Foreman services
podman network create foreman-net \
  --driver bridge \
  --subnet 172.20.0.0/16
```

### Service Discovery
```ini
# Use container names for service discovery
[Container]
Network=foreman-net
Environment=DATABASE_HOST=foreman-db
Environment=PROXY_HOST=foreman-proxy
```

### Port Management
```bash
# Service port allocation
443  -> foreman-web (HTTPS)
80   -> foreman-web (HTTP redirect)
8443 -> foreman-proxy (Smart Proxy API)
5432 -> postgres (database, internal only)
```

## Configuration Management Patterns

### Environment-Specific Configuration
```yaml
# group_vars/development.yml
foreman_image: foreman
foreman_version: nightly
foreman_debug: true
postgres_version: 13

# group_vars/production.yml
foreman_image: foreman
foreman_version: 3.12
foreman_debug: false
postgres_version: 15
```

### Secret Template Generation
```jinja2
# templates/database.yml.j2
production:
  adapter: postgresql
  host: {{ database_host }}
  port: {{ database_port }}
  database: {{ database_name }}
  username: {{ database_username }}
  password: {{ database_password }}
  pool: {{ database_pool_size }}
```

### Dynamic Configuration
```yaml
# Dynamic configuration based on inventory
- name: Generate database configuration
  set_fact:
    foreman_database_config:
      production:
        adapter: postgresql
        host: "{{ groups['database'][0] }}"
        database: "{{ foreman_db_name }}"
        username: "{{ foreman_db_user }}"
        password: "{{ foreman_db_password }}"
```

## Monitoring and Logging Patterns

### Health Check Integration
```ini
# Health check configuration in quadlets
[Container]
HealthCmd=/usr/bin/curl -f http://localhost/health
HealthInterval=30s
HealthTimeout=10s
HealthRetries=3
```

### Log Management
```bash
# Centralized logging with volumes
podman volume create foreman-logs

# Log rotation configuration
podman run --log-driver journald \
  --log-opt tag=foreman-web \
  foreman:latest
```

### Monitoring Integration
```yaml
# Prometheus monitoring setup
- name: Deploy node exporter
  containers.podman.podman_container:
    name: node-exporter
    image: prom/node-exporter:latest
    ports:
      - "9100:9100"
    volumes:
      - "/proc:/host/proc:ro"
      - "/sys:/host/sys:ro"
```

## Backup and Recovery Patterns

### Data Volume Backup
```bash
# Database backup
podman run --rm \
  --volumes-from foreman-db \
  -v /backup:/backup \
  postgres:13 \
  pg_dump -h foreman-db -U foreman foreman > /backup/foreman.sql

# Content backup
podman run --rm \
  --volumes-from pulp-content \
  -v /backup:/backup \
  alpine tar czf /backup/pulp-content.tar.gz /var/lib/pulp
```

### Configuration Backup
```yaml
# Ansible backup playbook
- name: Backup container configurations
  archive:
    path:
      - /etc/containers/systemd/
      - /etc/foreman-installer/
    dest: "/backup/foreman-config-{{ ansible_date_time.epoch }}.tar.gz"
```

## Security Patterns

### Secret Rotation
```yaml
# Automated secret rotation
- name: Generate new database password
  set_fact:
    new_db_password: "{{ lookup('password', '/dev/null length=32 chars=ascii_letters,digits') }}"

- name: Update database password secret
  containers.podman.podman_secret:
    name: foreman-db-password
    data: "{{ new_db_password }}"
    force: true

- name: Restart dependent services
  systemd:
    name: "{{ item }}"
    state: restarted
  loop:
    - foreman-web
    - foreman-worker
```

### Image Security
```yaml
# Container image scanning
- name: Scan container images
  shell: |
    podman run --rm \
      -v /var/run/docker.sock:/var/run/docker.sock \
      aquasec/trivy image {{ foreman_image }}:{{ foreman_version }}
```