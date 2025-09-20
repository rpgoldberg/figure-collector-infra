# Figure Collector Services - Cross-Service Orchestration

## 🎯 ORCHESTRATOR RESPONSIBILITIES

**This Claude instance serves as the CROSS-SERVICE ORCHESTRATOR for the Figure Collector application.**

**PRIMARY ROLE**: Coordinate activities across multiple services, manage sub-agents, and delegate service-specific work to local Claude instances.

**DO NOT**: Implement service-specific features directly. Instead, delegate to local Claude instances in each service directory.

**ORCHESTRATOR WORKFLOW**:
1. **Analyze cross-service requirements** and dependencies
2. **Plan multi-service coordination** using TodoWrite
3. **Delegate service-specific work** to local Claude instances
4. **Coordinate sub-agent improvements** across all services  
5. **Provide next-action instructions** for service implementations

## Service Directories

- **figure-collector-backend/** - Node.js/Express/TypeScript API service
- **figure-collector-frontend/** - React/TypeScript frontend application  
- **page-scraper/** - Puppeteer/TypeScript web scraping service
- **version-manager/** - Node.js/JavaScript version management service
- **figure-collector-integration-tests/** - Docker/Jest integration testing
- **figure-collector-infra/** - Infrastructure, deployment, and CI/CD

## Cross-Service Coordination Pattern

**FOR ORCHESTRATOR (this Claude instance)**:
- Analyze multi-service requirements
- Plan cross-service dependencies  
- Coordinate sub-agent improvements
- Delegate service work to local Claude instances

**FOR SERVICE-SPECIFIC WORK**:
```bash
cd figure-collector-backend
claude-code  # Local Claude handles backend implementation

cd ../version-manager  
claude-code  # Local Claude handles version service implementation
```

**Each service has its own local Claude instance with service-specific agents and instructions.**

## Code Analysis and Search Strategy

**USE STANDARD CLAUDE CODE TOOLS**: Use Read, Grep, Glob, and other standard tools for code analysis and search across all four project repositories:
- **figure-collector-backend** (Node.js/Express/TypeScript)
- **figure-collector-frontend** (React/TypeScript) 
- **page-scraper** (Puppeteer/TypeScript)
- **version-manager** (Node.js/JavaScript) - Standalone repository

### Code Search Best Practices

**ALWAYS use standard tools for**:
- Code exploration and symbol discovery: `Grep` with patterns
- Understanding code relationships: `Grep` and `Read` for imports/exports
- Searching for patterns: `Grep` with regex patterns
- Getting file overviews: `Read` with appropriate limits
- Reading project structure: `LS` and `Glob`

### Project Context Management

**CRITICAL**: This is NOT a monorepo - treat as 4 separate services.

**Project Navigation Pattern**:
- Use absolute paths when targeting specific services
- Example: `/home/rgoldberg/projects/figure-collector-services/figure-collector-backend/`
- Use Glob patterns for multi-file searches within services

## Sub-Agent Strategy

### Atomic Task Principle
- All sub-agents should be designed for atomic, focused tasks
- Use **Sonnet model** for all sub-agents for enhanced capabilities
- Sub-agents should have single, well-defined responsibilities

### Test Generation Orchestration Pattern

When implementing comprehensive test suites:

1. **Create specialized sub-agents** for each service/component
2. **Run sub-agents in parallel** using single message with multiple Task tool calls
3. **Use atomic focus** - one sub-agent per service, not per test type
4. **Always specify Sonnet model** in sub-agent configurations

### Sub-Agent Discovery Process

When looking for custom agents:
- Always search from project root with `find . -name ".claude" -type d`
- Check for `.claude/agents/*.md` files systematically
- Use `find /path/to/project -name "*.md" | grep -i "agent-name"` for specific agents
- Follow the proactive agent usage patterns defined below

### Model Selection Guidelines

- **Primary Agent (Claude)**: Use Sonnet for orchestration and complex decision-making
- **Sub-Agents**: Use Sonnet for atomic, focused tasks (testing, documentation, validation)
- **Exception**: Use Sonnet only if sub-agent requires complex reasoning or large context

### Proactive Agent Usage

Always call these agents automatically after code changes:
- `documentation-manager` - After any code modifications
- Test validation agents - After test implementation

### Task Management

- Use **TodoWrite tool** for planning and tracking complex, multi-step tasks
- Break down large implementations into atomic sub-tasks
- Mark tasks as in_progress → completed as work is done
- Provide visibility into progress for complex orchestrations

### Git Management

- Always commit changes in **logical chunks** per service/component
- Use concise commit messages (50-80 words, 160 max) matching existing patterns - **ABSOLUTELY NO Claude Code attribution or co-authored metadata**
- **CRITICAL TEST VALIDATION LOOP**: Always run validation-gates agent after code changes
- Verify all tests pass before committing
- Get approval from documentation-manager and validation-gates before committing
- Call documentation-manager after commits to update docs

## Orchestrator Responsibilities

### Cross-Service Coordination
- **Multi-service feature planning**: Analyze requirements spanning multiple services
- **Dependency management**: Coordinate service interactions and API contracts
- **Integration testing coordination**: Oversee end-to-end testing across services
- **Sub-agent management**: Create, refine, and improve agents across all services
- **Release coordination**: Plan and coordinate multi-service deployments

### Local Claude Delegation Patterns
When coordinating service work:

1. **Analyze cross-service requirements**
2. **Break down into service-specific tasks**
3. **Provide clear instructions for each local Claude**
4. **Coordinate timing and dependencies**
5. **Validate integration points**

### Example Delegation:
```
NEXT ACTIONS for [USER]:

1. Backend (figure-collector-backend):
   cd figure-collector-backend && claude-code
   "Implement user authentication API endpoints with JWT tokens"

2. Frontend (figure-collector-frontend):  
   cd figure-collector-frontend && claude-code
   "Create login/register components that integrate with backend auth API"

3. Integration Testing:
   cd figure-collector-integration-tests && claude-code
   "Add authentication flow tests between frontend and backend"
```

## Available Orchestrator Agents

### Cross-Service Management (Sonnet - This Instance)
- **Sub-agent refinement**: Improve agents across all services
- **Cross-service planning**: Coordinate multi-service features
- **Integration oversight**: Manage service dependencies
- **Release coordination**: Plan deployment sequences

### Service-Local Agents (Delegated to Local Claude Instances)
- `test-generator-backend` - Jest + Supertest for Node.js/Express services
- `test-generator-frontend` - React Testing Library + Jest for React apps
- `test-generator-scraper` - Jest + Puppeteer mocking for scraping services
- `test-generator-version-manager` - Jest + Supertest for version management services
- `test-generator-integration` - Docker-based integration testing
- `infrastructure-manager` - Infrastructure automation and deployment
- `documentation-manager` - Synchronizes documentation with code changes
- `validation-gates` - Testing and validation specialist

## File Structure

```
.claude/
├── agents/
│   ├── documentation-manager.md
│   ├── test-orchestrator.md
│   ├── test-generator-backend.md
│   ├── test-generator-frontend.md
│   ├── test-generator-scraper.md
│   ├── test-generator-version-manager.md
│   └── ... (add more as needed)
└── commands/
    └── primer.md
```

## Manual Orchestration Pattern

### Quick Reference for Multi-Step Tasks

When encountering complex tasks requiring multiple atomic operations:

#### 1. **Don't use test-orchestrator** ❌ 
- It's broken (no Task tool, uses Sonnet, false reporting)
- Use manual orchestration instead

#### 2. **Manual Orchestration Pattern** ✅

```markdown
1. Use TodoWrite to plan atomic tasks
2. Call sub-agents directly with Task tool
3. Force Sonnet with MODEL_OVERRIDE on every call
4. Verify each completion before proceeding
5. Update TodoWrite with progress
```

#### 3. **Required Sub-Agent Call Format** 

```
Task:
subagent_type: test-generator-backend
description: [Brief atomic task]
prompt:
MODEL_OVERRIDE: sonnet
AGENT_MODEL: sonnet

ATOMIC TASK: [Specific focused task]

REQUIREMENTS:
- [Clear requirements]
- Keep atomic and focused
- Report completion

Start with: I am using [MODEL_NAME] to [specific task].
```

#### 4. **Verification Checklist**

After each sub-agent call:
- ✅ Confirmed Sonnet model usage
- ✅ Task stayed atomic/focused  
- ✅ Files actually modified/created
- ✅ Changes work as expected
- ✅ Clear completion report provided

### Available Working Sub-Agents

- **test-generator-backend**: Jest, API tests, DB setup, mocking
- **test-generator-frontend**: React tests, UI testing, accessibility  
- **test-generator-scraper**: Jest + Puppeteer mock test suites for web scraping services
- **test-generator-version-manager**: Jest + Supertest test suites for lightweight Node.js/Express version services
- **validation-gates**: Testing and validation specialist, runs tests and ensures quality gates are met
- **documentation-manager**: README, API docs, technical guides

### Testing Environment Notes

**MongoDB Atlas Search Testing**:
- ✅ MongoDB Memory Server implemented
- ✅ Atlas Search mocking with user isolation
- ✅ Dual mode: memory (CI/CD) vs atlas (local dev)
- Test scripts: `npm run test:memory` and `npm run test:atlas`

**WSL Setup**:
- Install Node.js via NVM (see WSL_TEST_FIX_SOLUTION.md)
- Ensures npm and node both use Linux paths

**Testing Enhancements**:
- Improved WSL compatibility across services
- Enhanced TypeScript test configurations
- Added accessibility testing with jest-axe
- Standardized test coverage reporting
- Implemented comprehensive mock configurations
- Resolved Docker build failures with TypeScript compilation fixes

**Current Test Coverage**:
- Version Service: 55 tests, 76.11% coverage
- Backend: WSL compatibility improved
- Page Scraper: TypeScript fixes applied
- Frontend: React test configuration enhanced

### Project-Specific Context

**Figure Collector Services**:
- Backend: Node.js/Express with MongoDB Atlas
- Frontend: React with Chakra UI  
- Scraper: Puppeteer-based web scraping
- Version Service: Lightweight version management

**Search Functionality**:
Uses MongoDB Atlas Search with `$search` aggregation:
```javascript
Figure.aggregate([{
  $search: {
    index: 'figures',
    compound: {
      must: [{
        text: {
          query: query,
          path: ['manufacturer', 'name', 'location', 'boxNumber']
        }
      }]
    }
  }
}])
```

### Success Pattern

When orchestration works correctly:
1. **Plan** tasks atomically with TodoWrite
2. **Delegate** with proper MODEL_OVERRIDE forcing
3. **Verify** Sonnet usage and file changes
4. **Progress** systematically through atomic tasks
5. **Document** results and any remaining issues

This approach delivers the intended atomic Sonnet sub-agent architecture without relying on the broken test-orchestrator.