# Infrastructure Service Claude Configuration

## Technology Stack
- Docker
- Deployment Automation
- CI/CD Configuration
- Infrastructure as Code
- Service Orchestration

## Service-Specific Configuration Approaches

### Infrastructure Management
- Docker containerization
- Multi-stage builds
- Service deployment configurations
- Environment-specific setups
- Security and performance optimization

### Deployment Strategies
- Docker Compose configurations
- Cloudflare tunnel setup
- MongoDB Atlas integration
- WSL2 compatibility
- Cross-platform deployment support

## Development Workflow

### Key Management Commands
- `./deploy.sh`: Primary deployment script
- `docker-compose up`: Local service orchestration
- `docker build`: Build individual service containers
- `./scripts/test-tls.sh`: TLS configuration testing

## Available Sub-Agents

### Atomic Task Agents (Haiku Model)
- **`infrastructure-manager`**: Infrastructure automation and deployment specialist
  - Docker configuration and multi-stage builds
  - Deployment automation and CI/CD pipelines
  - Service orchestration and scaling
  - Security hardening and compliance
  
- **`documentation-manager`**: Documentation synchronization specialist
  - Updates README and deployment docs after code changes
  - Maintains documentation accuracy
  - Synchronizes docs with code modifications
  
- **`validation-gates`**: Testing and validation specialist
  - Runs comprehensive test suites
  - Validates code quality gates
  - Iterates on fixes until all tests pass
  - Ensures production readiness

## Agent Invocation Instructions

### Manual Orchestration Pattern (Required)
Use TodoWrite to plan tasks, then call sub-agents directly with proper Haiku configuration:

```
Task:
subagent_type: infrastructure-manager
description: Manage infrastructure and deployment
prompt:
MODEL_OVERRIDE: claude-3-haiku-20240307
AGENT_MODEL: haiku

ATOMIC TASK: Configure infrastructure and deployment automation

REQUIREMENTS:
- Optimize Docker configurations and builds
- Implement deployment automation
- Configure service orchestration
- Ensure security and performance
- Follow infrastructure best practices

Start with: I am using claude-3-haiku-20240307 to manage infrastructure configuration.
```

### Post-Implementation Validation
Always call validation-gates after implementing features:

```
Task:
subagent_type: validation-gates
description: Validate infrastructure implementation
prompt:
MODEL_OVERRIDE: claude-3-haiku-20240307

ATOMIC TASK: Validate all tests pass and quality gates are met

FEATURES IMPLEMENTED: [Specify what was implemented]
VALIDATION NEEDED: Run deployment tests, check security, ensure quality

Start with: I am using claude-3-haiku-20240307 to validate implementation quality.
```

### Documentation Updates
Call documentation-manager after code changes:

```
Task:
subagent_type: documentation-manager  
description: Update documentation after changes
prompt:
MODEL_OVERRIDE: claude-3-haiku-20240307

ATOMIC TASK: Synchronize documentation with code changes

FILES CHANGED: [List of modified files]
CHANGES MADE: [Brief description of changes]

Start with: I am using claude-3-haiku-20240307 to update documentation.
```

## Docker Build Example
```bash
# Multi-stage build example
docker build \
  -t figure-collector-backend \
  -f Dockerfile.backend \
  --target production \
  .
```

## Atomic Task Principles
- Validate individual deployment configurations
- Test service containerization
- Ensure cross-platform compatibility
- Verify secure deployment practices
- Optimize infrastructure performance

## File Structure

```
.claude/
├── agents/
│   ├── infrastructure-manager.md
│   ├── documentation-manager.md
│   └── validation-gates.md
└── commands/
    └── primer.md
```

## Quality Assurance Workflow

1. **Implementation**: Write infrastructure changes
2. **Configuration**: Call `infrastructure-manager` for deployments
3. **Validation**: Call `validation-gates` to ensure quality
4. **Documentation**: Call `documentation-manager` to update docs
5. **Verification**: Confirm all deployments work and docs are current