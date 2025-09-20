# Figure Collector Services - Agent Orchestration Hierarchy

## 🎯 Orchestration Architecture

### Master Orchestrator (figure-collector-infra)
**Model**: Default (up to 50% Opus, then Sonnet)
**Role**: Cross-service coordination and delegation

#### Master-Level Agents (Sonnet)
- `cross-service-planner` - Multi-service feature decomposition
- `integration-validator` - Cross-service integration testing
- `deployment-orchestrator` - Multi-service release coordination
- `architecture-reviewer` - System design validation

### Service Orchestrators
**Model**: Default (up to 50% Opus, then Sonnet)
**Role**: Service-specific coordination, reports to master

## 📦 Service-Specific Agents

### Backend Service (figure-collector-backend)
**Orchestrator**: Service-level coordinator
#### Agents (Sonnet):
- `api-builder` - REST endpoint implementation
- `data-architect` - MongoDB schema and queries
- `auth-guardian` - JWT authentication/authorization
- `test-engineer` - Jest/Supertest test suites

### Frontend Service (figure-collector-frontend)
**Orchestrator**: Service-level coordinator
#### Agents (Sonnet):
- `ui-composer` - React component development
- `state-manager` - Redux/Context state management
- `api-integrator` - Backend API integration
- `test-specialist` - React Testing Library tests

### Scraper Service (page-scraper)
**Orchestrator**: Service-level coordinator
#### Agents (Sonnet):
- `automation-expert` - Puppeteer browser automation
- `data-extractor` - Scraping logic and selectors
- `resilience-engineer` - Error handling and retries
- `test-architect` - Mock-based test implementation

### Version Manager (version-manager)
**Orchestrator**: Service-level coordinator
#### Agents (Sonnet):
- `compatibility-guardian` - Version compatibility validation
- `registry-manager` - Service registration handling
- `config-specialist` - Environment configuration
- `test-validator` - Integration test validation

### Integration Tests (figure-collector-integration-tests)
**Orchestrator**: Service-level coordinator
#### Agents (Sonnet):
- `scenario-designer` - E2E test scenario creation
- `docker-coordinator` - Container orchestration
- `data-validator` - Cross-service data validation
- `performance-monitor` - Performance testing

### Infrastructure (figure-collector-infra)
**Orchestrator**: Service-level coordinator
#### Agents (Sonnet):
- `container-architect` - Docker configuration
- `deployment-engineer` - CI/CD pipeline management
- `security-guardian` - Security implementation
- `pipeline-builder` - GitHub Actions workflows

## 🔄 Common Agents (Cross-Service)

### Shared Specialists (Sonnet)
- `documentation-manager` - Documentation synchronization
- `validation-gates` - Quality gate enforcement

## 📋 Reporting Chain

```
Agents → Service Orchestrator → Master Orchestrator
```

### Status Protocol
1. **Agents** report task completion to service orchestrator
2. **Service Orchestrators** aggregate status to master
3. **Master Orchestrator** coordinates cross-service activities

### Model Selection Rules
- **Master/Service Orchestrators**: Default model (Opus → Sonnet)
- **All Custom Agents**: Sonnet (unless overridden)
- **Override Format**: `MODEL_OVERRIDE: claude-3-haiku-20240307`

## 🚀 Usage Patterns

### Single Service Task
```bash
cd figure-collector-backend
# Local orchestrator delegates to appropriate agent
```

### Cross-Service Feature
```bash
# Master orchestrator:
# 1. Uses cross-service-planner to decompose
# 2. Delegates to service orchestrators
# 3. Monitors via integration-validator
```

### Deployment Flow
```bash
# deployment-orchestrator coordinates:
# 1. Version validation
# 2. Container builds
# 3. Service deployments
# 4. Integration tests
```

## 📝 Agent Invocation

### Direct Agent Call
```yaml
Task:
  subagent_type: api-builder
  description: "Implement user endpoints"
  prompt: |
    SERVICE: backend
    TASK: Create CRUD endpoints for user management
    REQUIREMENTS:
    - JWT authentication
    - Input validation
    - Error handling
```

### Orchestrator Delegation
```yaml
# Master delegates to service:
NEXT ACTIONS for Backend Orchestrator:
- Implement user authentication
- Use api-builder for endpoints
- Use auth-guardian for JWT
- Report completion status
```

## ⚠️ Deprecated Agents

The following agents have been removed:
- `test-generator-*` series (replaced by service-specific test agents)
- `test-orchestrator` (replaced by hierarchical orchestration)
- Generic test generators (replaced by specialized agents)

## 🔧 Maintenance

### Adding New Agents
1. Create agent file in service's `.claude/agents/`
2. Update service CLAUDE.md with agent reference
3. Define reporting protocol
4. Test with service orchestrator

### Updating Orchestration
1. Modify CLAUDE.md for directive changes
2. Update primer.md for initialization
3. Ensure reporting chain intact
4. Validate model selection

---
*Last Updated: January 2025*
*Architecture Version: 2.0 - Hierarchical Orchestration*