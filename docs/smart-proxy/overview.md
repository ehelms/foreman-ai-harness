---
title: Smart Proxy Overview
type: note
permalink: foreman/smart-proxy-overview
---

# Smart Proxy Overview

The smart-proxy is a critical component of the Foreman ecosystem that acts as a bridge between Foreman and various services on managed hosts.

## Architecture
- Ruby-based Sinatra application
- Plugin-based architecture with modular design
- RESTful API interface
- Dependency injection system for plugins

## Modern Implementations
- **Traditional**: Single Ruby Sinatra process with plugins
- **Containerized**: Modern deployments like IOP use nginx gateway facade implementing standard smart-proxy API, routing to internal microservices while maintaining full compatibility

## Key Modules
- **DHCP**: ISC DHCP, libvirt, Native MS DHCP
- **DNS**: nsupdate, dnscmd, libvirt DNS
- **TFTP**: File serving for network boot
- **Puppet**: Certificate authority and class information
- **BMC**: IPMI, Redfish for hardware management
- **Facts**: System information collection
- **Realm**: FreeIPA/AD integration
- **Templates**: Provisioning template proxy
- **Registration**: Host registration endpoints

## Configuration
- Settings in `/config/settings.yml` and `/config/settings.d/`
- Plugin-specific configuration files
- SSL certificate management

## Registration Pattern
- **Standard flow**: OAuth consumer key/secret for initial registration via foreman_smartproxy resource
- **Operational auth**: SSL client certificates (mutual TLS) for ongoing communication
- **Compatible implementations**: Both traditional Ruby and modern containerized deployments follow this pattern

## Current Working Directory
`/home/ehelms/workspace/upstream/app-code/smart-proxy`

## Development Status
- Current branch: develop
- Recent commits include userdata API extensions, HSTS middleware, Ruby 3.4 support