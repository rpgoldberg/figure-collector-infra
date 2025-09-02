# Agent Orchestration Directives

## 🚨 CRITICAL: test-orchestrator is BROKEN - DO NOT USE

**Status**: test-orchestrator agent is fundamentally flawed and should be removed from available agents.

**Issues**:
- ❌ Missing Task tool - Cannot delegate to sub-agents
- ❌ Uses Sonnet instead of coordinating Haiku sub-agents  
- ❌ False reporting - Claims delegation that never happened
- ❌ Defeats orchestration purpose by doing work itself

**Solution**: Manual orchestration with direct Haiku sub-agent calls.

## ✅ WORKING AGENT ORCHESTRATION PATTERN

### For Claude Code Main Agent (Sonnet)

When complex multi-step tasks require atomic sub-agent work:

1. **Act as the orchestrator yourself**
2. **Call sub-agents directly** using Task tool
3. **Force Haiku usage** on every sub-agent call
4. **Track progress** using TodoWrite tool
5. **Verify sub-agent work** before proceeding

### Required Sub-Agent Call Pattern

**ALWAYS use this exact format for sub-agent calls:**

```
Task:
- subagent_type: test-generator-backend (or other specific agent)
- description: Brief atomic task description
- prompt: 
  MODEL_OVERRIDE: claude-3-haiku-20240307
  AGENT_MODEL: haiku
  REQUIRED_MODEL: haiku
  
  ATOMIC TASK: [Specific focused task]
  
  REQUIREMENTS:
  - [Clear, specific requirements]
  - Keep task atomic and focused
  - Report what was accomplished
  
  Start with: I am using [MODEL_NAME] to [do specific task].
```

### Sub-Agent Verification Checklist

After each sub-agent call, verify:
- ✅ Agent confirmed using Haiku model
- ✅ Task was atomic and focused  
- ✅ Actual files were modified/created
- ✅ Changes compile and work as expected
- ✅ Agent provided clear completion report

## 🎯 EFFECTIVE TASK DELEGATION PATTERNS

### Backend Testing (test-generator-backend)
**Use for**: Jest tests, API testing, database setup, mocking

**Atomic Tasks**:
- Install specific dependencies
- Create single test file
- Fix TypeScript compilation errors
- Setup database connections
- Add specific mocking functions

**Example Call**:
```
Task:
subagent_type: test-generator-backend
description: Create unit tests for Atlas Search mocking
prompt:
MODEL_OVERRIDE: claude-3-haiku-20240307
AGENT_MODEL: haiku

ATOMIC TASK: Create tests/unit/atlasSearchMock.test.ts

REQUIREMENTS:
- Test mockAtlasSearch function with various queries
- Test user isolation in search results
- Test empty query handling
- Use Jest and existing test patterns

Files to create: tests/unit/atlasSearchMock.test.ts only

Start with: I am using [MODEL_NAME] to create Atlas Search unit tests.
```

### Frontend Testing (test-generator-frontend)  
**Use for**: React component tests, UI testing, accessibility tests

**Atomic Tasks**:
- Create component test files
- Add accessibility testing
- Test user interactions
- Mock API calls in frontend tests

### Documentation (documentation-manager)
**Use for**: README updates, API documentation, technical docs

**Atomic Tasks**:
- Update specific README sections
- Document new API endpoints
- Create technical implementation guides
- Sync docs with code changes

## 🚫 WHAT NOT TO DELEGATE

Keep these tasks with main agent (Sonnet):
- Complex analysis and planning
- Multi-service coordination  
- Architecture decisions
- Error diagnosis across multiple files
- WSL/Windows environment troubleshooting

## 📋 ORCHESTRATION WORKFLOW

### 1. Task Assessment
```
Is this task:
- Multi-step? → Break into atomic tasks for sub-agents
- Single complex analysis? → Handle yourself
- Requires multiple file coordination? → Handle yourself  
- Atomic and focused? → Delegate to appropriate Haiku sub-agent
```

### 2. Delegation Process
```
For each atomic task:
1. Call appropriate sub-agent with MODEL_OVERRIDE
2. Verify Haiku model usage in response
3. Check actual file changes were made
4. Update TodoWrite with completion status
5. Proceed to next atomic task
```

### 3. Verification Process
```
After sub-agent work:
1. Read modified files to verify changes
2. Test compilation if applicable  
3. Run relevant tests if possible
4. Document any issues for next sub-agent call
```

## ⚠️ COMMON PITFALLS TO AVOID

1. **Never use test-orchestrator** - It's broken beyond repair
2. **Always use MODEL_OVERRIDE** - Sub-agents default to Sonnet without it
3. **Keep tasks atomic** - One file, one function, one specific change
4. **Verify model usage** - Sub-agents should confirm Haiku usage
5. **Don't batch complex tasks** - Break into smaller atomic pieces

## 🔧 TROUBLESHOOTING

### If sub-agent doesn't confirm Haiku usage:
- Add more explicit model forcing in prompt
- Try different phrasing: "You MUST use Haiku model"
- Verify MODEL_OVERRIDE is first line of prompt

### If sub-agent does work but no file changes:
- Agent may have misunderstood task scope
- Re-delegate with more specific file paths
- Verify agent has write permissions

### If sub-agent provides Sonnet-style verbose response:
- Model override failed, try again with stronger forcing
- Break task into smaller atomic piece
- Use different sub-agent type

## 📊 SUCCESS METRICS

**Effective Haiku Sub-Agent Orchestration**:
- ✅ Agent confirms Haiku model usage
- ✅ Concise, focused responses (not verbose Sonnet style)
- ✅ Actual file modifications occur
- ✅ Tasks completed atomically 
- ✅ Clear completion reporting

**When orchestration is working**:
- Sub-agents stay focused on assigned atomic tasks
- Each agent completes work before next delegation
- File changes are verified and functional
- Progress tracked systematically with TodoWrite

This orchestration pattern delivers the intended atomic Haiku sub-agent architecture that was promised but not delivered by the broken test-orchestrator agent.