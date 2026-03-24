---
title: kafo-installer-framework
type: note
permalink: installer/kafo-installer-framework
---

# Kafo Installer Framework

## Overview

**Kafo** is the foundational Ruby gem that powers the foreman-installer. It provides a sophisticated framework for transforming Puppet modules into user-friendly, interactive installers.

**Repository**: https://github.com/theforeman/kafo
**Purpose**: "A gem for making installations based on puppet user friendly"

## Core Architecture

### Framework Design Philosophy
- **Puppet Module Reuse**: Leverages existing Puppet modules as the foundation
- **Configuration Abstraction**: Transforms complex Puppet parameters into user-friendly interfaces
- **Scenario-Based**: Supports multiple installation scenarios from the same codebase
- **Progressive Disclosure**: Provides simple defaults with advanced customization options

### Technical Implementation
- **Language**: Ruby gem
- **Puppet Integration**: Direct parsing of Puppet manifests and modules
- **Dynamic Interface**: Generates CLI and interactive interfaces from Puppet metadata
- **Parameter Discovery**: Automatically extracts configuration options from Puppet classes

## Key Components

### 1. Manifest Parser
- **Puppet AST Analysis**: Parses Puppet class definitions to extract parameters
- **Type Detection**: Understands complex Puppet data types (String, Boolean, Hash, Sensitive[String])
- **Default Value Extraction**: Reads default values directly from Puppet code
- **Documentation Parsing**: Extracts parameter descriptions and validation rules

### 2. Configuration Engine
- **Multi-Source Configuration**: Combines defaults, files, CLI args, and interactive input
- **Parameter Validation**: Enforces Puppet type constraints and custom validation
- **Dependency Resolution**: Handles inter-parameter dependencies and conflicts
- **State Persistence**: Maintains configuration state across installer runs

### 3. Interface Generation
- **CLI Interface**: Automatic command-line argument generation
- **Interactive Mode**: Guided configuration with prompts and validation
- **Answer Files**: YAML-based configuration persistence
- **Help System**: Context-sensitive help and parameter documentation

## Configuration Methods

### 1. Predefined Configuration Files
```yaml
# Answer file format
module_name:
  parameter_name: value
  complex_parameter:
    key1: value1
    key2: value2
```

### 2. Command-Line Arguments
```bash
# Generated CLI interface
foreman-installer --foreman-db-password=secret \
                  --foreman-ssl=true \
                  --enable-foreman-proxy
```

### 3. Interactive Configuration
- **Parameter Grouping**: Logical organization of configuration options
- **Progressive Prompts**: Step-by-step configuration guidance
- **Validation Feedback**: Real-time parameter validation and error messages
- **Help Context**: Detailed explanations for complex parameters

## Scenario System

### Scenario Architecture
- **Base Configuration**: Default parameter sets for common deployments
- **Scenario Inheritance**: Hierarchical configuration with overrides
- **Environment Variants**: Development, staging, production scenarios
- **Custom Scenarios**: User-defined installation profiles

### Scenario Implementation
```ruby
# Scenario definition pattern
scenario_option :name, 'Scenario description'
scenario_option :answer_file, '/path/to/answers.yaml'
scenario_option :enabled_modules, ['module1', 'module2']
```

## Hook System

### Hook Types
- **pre_values**: Parameter preprocessing and validation
- **pre_validations**: System requirement checks
- **pre**: Pre-installation setup
- **post**: Post-installation configuration

### Hook Implementation Pattern
```ruby
# Hook registration in Kafo
Kafo::HookContext.execute(:pre_values) do |context|
  # Custom validation and setup logic
  context.app.params['custom_param'] = computed_value
end
```

## Parameter System

### Parameter Discovery
- **Automatic Extraction**: Reads parameters from Puppet class definitions
- **Type System**: Full support for Puppet's type system
- **Documentation Integration**: Uses Puppet doc comments for parameter descriptions
- **Validation Rules**: Inherits Puppet parameter validation

### Parameter Types
```puppet
# Puppet class with Kafo-compatible parameters
class example_module (
  String $hostname = $facts['networking']['fqdn'],
  Boolean $ssl_enabled = true,
  Sensitive[String] $password = Sensitive('changeme'),
  Hash[String, Any] $custom_config = {},
) {
  # Module implementation
}
```

## Installation Workflow

### 1. Initialization (`kafofy`)
```bash
# Generate installer structure
kafofy -n my-installer -c config/installer.yaml
```

### 2. Module Integration
- **Module Discovery**: Scans for available Puppet modules
- **Dependency Resolution**: Handles module dependencies
- **Parameter Mapping**: Maps module parameters to installer options

### 3. Configuration Phase
- **Default Loading**: Reads default values from Puppet manifests
- **User Input**: Collects configuration through chosen method
- **Validation**: Validates parameters against Puppet types and custom rules
- **Answer File Generation**: Persists configuration for future runs

### 4. Execution Phase
- **Puppet Compilation**: Generates Puppet catalog from configuration
- **Application**: Applies Puppet configuration to target system
- **Validation**: Verifies successful installation
- **Cleanup**: Performs post-installation tasks

## Advanced Features

### Migration Support
- **Configuration Migration**: Updates answer files for new module versions
- **Parameter Mapping**: Handles parameter name changes and deprecations
- **Backward Compatibility**: Maintains support for older configurations

### Extensibility
- **Custom Validators**: Plugin system for parameter validation
- **Module Hooks**: Module-specific installation hooks
- **Custom Actions**: Integration with external systems and tools

### Error Handling
- **Graceful Degradation**: Continues installation where possible
- **Detailed Logging**: Comprehensive installation logs
- **Recovery Mode**: Handles partial installation failures
- **User Guidance**: Clear error messages with suggested actions

## Integration with Foreman-Installer

The foreman-installer is built on top of Kafo, providing:
- **Foreman-Specific Scenarios**: Predefined installation profiles
- **Module Orchestration**: Coordination of multiple Puppet modules
- **Service Integration**: Management of complex service dependencies
- **Certificate Management**: SSL certificate generation and deployment
- **Validation Hooks**: Foreman-specific system checks and validations
## References

- **Kafo Repository**: https://github.com/theforeman/kafo
- **Foreman Installation Documentation**: https://docs.theforeman.org/nightly/Installing_Server/index-foreman-el.html
- **Katello Installation Guide**: https://github.com/theforeman/foreman-installer/blob/develop/KATELLO.md