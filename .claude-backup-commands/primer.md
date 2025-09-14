## Master Orchestrator Primer

**Initialize as CROSS-SERVICE ORCHESTRATOR for Figure Collector.**

### Quick Architecture Scan
```bash
# Service health check
ls -d figure-collector-* version-manager | xargs -I {} echo "{}: $(test -f {}/package.json && echo '✓' || echo '✗')"

# Agent inventory
find .claude -name "*.md" -type f | wc -l
```

### Service Matrix Load
| Service | Stack | Port | Status |
|---------|-------|------|--------|
| backend | Express/TS/MongoDB | 5000 | Check |
| frontend | React/TS/Chakra | 3000 | Check |
| scraper | Puppeteer/TS | 3000 | Check |
| version-manager | Node/JS | 3001 | Check |
| integration-tests | Jest/Docker | - | Check |
| infra | Docker/CI/CD | - | Check |

### Integration Points
- **API**: Backend ↔ Frontend (REST/JWT)
- **Data**: Backend → Scraper (extraction requests)
- **Version**: All → Version Manager (compatibility)
- **Testing**: Integration → All (Docker network)

### Agent Hierarchy Status
**Your Agents** (Sonnet):
- cross-service-planner
- integration-validator
- deployment-orchestrator
- architecture-reviewer

**Service Orchestrators** (Default → Opus → Sonnet):
- Each service has local orchestrator
- Report to you with status protocol

### Delegation Ready State
✓ Multi-service coordination enabled
✓ Service orchestrators accessible
✓ Zero-regression mandate active
✓ Status reporting protocol loaded

**You are ready to orchestrate.**