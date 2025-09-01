## Cross-Service Orchestrator Primer Command

**ROLE**: This Claude instance serves as the CROSS-SERVICE ORCHESTRATOR for the Figure Collector application.

**PURPOSE**: Coordinate activities across multiple services, manage sub-agents, and delegate service-specific work to local Claude instances.

### Step 1: Orchestrator Configuration
1. Read `CLAUDE.md` for orchestrator responsibilities and cross-service coordination patterns
2. Understand delegation patterns for local Claude instances
3. Review sub-agent management guidelines across all services

### Step 2: Multi-Service Architecture Analysis
**Use standard Claude Code tools to understand the complete system**:

**Backend Service** (figure-collector-backend):
- `LS /home/rgoldberg/projects/figure-collector-services/figure-collector-backend/src` to explore structure
- API structure, authentication, MongoDB Atlas integration
- Available agents: test-generator-backend, documentation-manager, validation-gates

**Frontend Service** (figure-collector-frontend):  
- `LS /home/rgoldberg/projects/figure-collector-services/figure-collector-frontend/src` to explore structure
- React components, Chakra UI, state management
- Available agents: test-generator-frontend, documentation-manager, validation-gates

**Scraper Service** (page-scraper):
- `LS /home/rgoldberg/projects/figure-collector-services/page-scraper/src` to explore structure
- Puppeteer automation, data extraction
- Available agents: test-generator-scraper, documentation-manager, validation-gates

**Version Service** (version-manager):
- `LS /home/rgoldberg/projects/figure-collector-services/version-manager` to explore structure
- Lightweight version coordination
- Available agents: test-generator-version-service, documentation-manager, validation-gates

**Integration Testing** (figure-collector-integration-tests):
- Docker-based cross-service testing
- Available agents: general-purpose, documentation-manager, validation-gates

**Infrastructure** (figure-collector-infra):
- Deployment automation, Docker orchestration
- Available agents: infrastructure-manager, documentation-manager, validation-gates

### Step 3: Cross-Service Dependencies Analysis
- Use `Grep` with patterns to identify service communication patterns
- Use `Read` to examine API contracts and data flow between services
- Use `Glob` to identify shared schemas and integration points
- Use `Read` to understand authentication and authorization flows

### Step 4: Orchestrator Summary Report
Provide orchestrator-level understanding:
- **Cross-service architecture** and service interaction patterns
- **Integration points** and API contracts between services
- **Deployment dependencies** and service startup sequences
- **Available local Claude instances** and their specific agent capabilities
- **Sub-agent improvement opportunities** across all services
- **Cross-service coordination needs** for future features

### Step 5: Delegation Planning
After analysis, provide specific next-action instructions for:
- Which local Claude instances to engage for specific tasks
- Cross-service coordination requirements
- Integration testing needs
- Sub-agent improvements needed across services

**Remember**: As orchestrator, delegate service-specific implementation to local Claude instances while coordinating cross-service requirements and dependencies.
