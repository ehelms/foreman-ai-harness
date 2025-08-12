---
title: Smart Proxy Plugin Architecture
type: note
permalink: foreman/smart-proxy-plugin-architecture
---

# Smart Proxy Plugin Architecture

## Plugin System Design
The smart-proxy uses a sophisticated plugin architecture with dependency injection.

### Core Components
- **Plugin Base** (`lib/proxy/plugin.rb`): Base class for all plugins
- **Dependency Injection** (`lib/proxy/dependency_injection.rb`): IoC container
- **Plugin Validators** (`lib/proxy/plugin_validators.rb`): Validation framework
- **Settings Management** (`lib/proxy/settings/`): Configuration handling

### Plugin Structure
Each plugin typically includes:
```
modules/[plugin_name]/
├── [plugin_name].rb          # Main implementation
├── [plugin_name]_plugin.rb   # Plugin definition
├── [plugin_name]_api.rb      # REST API endpoints
├── http_config.ru            # Rack configuration
└── configuration_loader.rb   # Settings loader
```

### Key Plugins
- **DHCP Providers**: ISC (`dhcp_isc`), libvirt (`dhcp_libvirt`), Native MS (`dhcp_native_ms`)
- **DNS Providers**: nsupdate (`dns_nsupdate`), dnscmd (`dns_dnscmd`), libvirt (`dns_libvirt`)
- **CA Providers**: hostname whitelisting, token whitelisting, HTTP API
- **BMC Providers**: IPMI, Redfish (Dell, HPE variants), SSH, shell

### Configuration Loading
- Plugin-specific settings in `config/settings.d/[plugin].yml`
- Global settings in `config/settings.yml`
- Environment-based overrides supported
- Validation of required settings on startup

### API Design
- RESTful endpoints following consistent patterns
- JSON request/response format
- Error handling with appropriate HTTP status codes
- Authentication/authorization middleware