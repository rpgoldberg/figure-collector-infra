# Figure Collector Services - Orchestration Setup

## Purpose
This directory contains the master orchestration configurations for the Figure Collector Services project, enabling consistent cross-service coordination and development workflow setup.

## Quick Setup

### 1. Create Orchestration Workspace
```bash
# From any location, create the orchestration workspace
mkdir -p ~/projects/figure-collector-services

# Copy orchestrator configuration to workspace root
cp figure-collector-infra/orchestration/CLAUDE.md ~/projects/figure-collector-services/
cp -r figure-collector-infra/orchestration/.claude ~/projects/figure-collector-services/

# Clone/link all services into workspace
cd ~/projects/figure-collector-services
# ... clone or symlink your service repositories here
```

### 2. Activate Orchestration Mode
```bash
cd ~/projects/figure-collector-services
claude-code  # Starts with orchestration CLAUDE.md configuration
```

## Service Architecture

The orchestration workspace expects this structure:
```
figure-collector-services/               # Orchestration root
├── CLAUDE.md                           # Orchestrator configuration
├── .claude/                           # Orchestrator agents
├── figure-collector-backend/          # Backend service repo
├── figure-collector-frontend/         # Frontend service repo  
├── page-scraper/                      # Scraping service repo
├── version-manager/                   # Version service repo
├── figure-collector-integration-tests/ # Integration tests repo
└── figure-collector-infra/            # Infrastructure repo (this one)
```

## Orchestration Workflow

### Cross-Service Coordination
1. **Analyze** requirements spanning multiple services
2. **Plan** coordination using TodoWrite tool
3. **Delegate** service-specific work to local Claude instances
4. **Validate** integration points and dependencies

### Service Delegation Pattern
```bash
# Example: Multi-service feature implementation
cd figure-collector-backend && claude-code
# "Implement authentication API endpoints"

cd ../figure-collector-frontend && claude-code  
# "Create login components integrating with backend API"

cd ../figure-collector-integration-tests && claude-code
# "Add end-to-end authentication flow tests"
```

## Agent Architecture

### Orchestrator Agents (Sonnet Model)
- Cross-service planning and coordination
- Sub-agent management and improvement
- Integration testing oversight
- Release coordination

### Service-Local Agents (Haiku Model)
- `test-generator-backend` - Node.js/Express testing
- `test-generator-frontend` - React testing with accessibility
- `test-generator-scraper` - Puppeteer mock testing  
- `test-generator-version-manager` - Version management testing
- `documentation-manager` - Documentation synchronization
- `validation-gates` - Quality assurance and test validation

## Testing Strategy

### Multi-Mode Testing Environment
- **Memory Mode**: MongoDB Memory Server for CI/CD
- **Atlas Mode**: Real MongoDB Atlas for local development
- **Integration Mode**: Docker-based cross-service testing

### Test Orchestration
1. Service-specific unit tests (local Claude instances)
2. Integration tests (orchestrator coordination)
3. End-to-end workflows (cross-service validation)

## Development Best Practices

### Atomic Task Management
- Use TodoWrite for complex multi-step tasks
- Force Haiku model for all sub-agents with MODEL_OVERRIDE
- Verify each sub-agent completion before proceeding
- Maintain single responsibility per agent

### Quality Gates
- Always run validation-gates after code changes
- Ensure all tests pass before commits
- Update documentation after modifications
- Coordinate releases across services

## Restoration Commands

### Save Current Orchestration State
```bash
# Backup current orchestration to infrastructure
cp ~/projects/figure-collector-services/CLAUDE.md figure-collector-infra/orchestration/
cp -r ~/projects/figure-collector-services/.claude figure-collector-infra/orchestration/
```

### Restore Orchestration Setup
```bash
# Restore from infrastructure backup
cp figure-collector-infra/orchestration/CLAUDE.md ~/projects/figure-collector-services/
cp -r figure-collector-infra/orchestration/.claude ~/projects/figure-collector-services/
```

This setup enables consistent, scalable orchestration while maintaining the independence of individual service repositories.