# Git Flow & Versioning Workflow Reference

## Overview

This document provides the exact command sequences for managing git flow and versioning across the Figure Collector microservices architecture.

## Repository Structure

- `figure-collector-backend/` - Backend service repository
- `figure-collector-frontend/` - Frontend service repository  
- `page-scraper/` - Standalone scraping service repository
- `version-manager/` - Version management service repository
- `figure-collector-integration-tests/` - Docker-based integration testing suite
- `figure-collector-infra/` - Infrastructure and cross-service orchestration repository

## Core Principles

1. **Develop branch is protected** - all changes require PRs (including version bumps)
2. **Version bumps via PR** - create feature branch → bump version → PR to develop
3. **Tag AFTER merge and build verification** - never tag before Docker builds confirm success
4. **Main branch** gets merges from develop via release branches for production
5. **Each service versions independently**
6. **Application releases coordinate service versions**

## Complete Workflow Example

### Scenario: Adding new backend API endpoint

```bash
# === PHASE 1: Feature Development ===
cd figure-collector-backend
git checkout develop
git pull origin develop
git checkout -b feature/add-endpoint

# ... code the feature ...
git add .
git commit -m "Add new user stats API endpoint"
git commit -m "Add validation for stats endpoint"  
git commit -m "Add tests for user stats"
git push origin feature/add-endpoint

# === PHASE 2: PR and Review ===
# Create PR: feature/add-endpoint → develop (via GitHub/GitLab UI)
# Review, approve, merge

# === PHASE 3: Version Bumping (VIA PR TO DEVELOP) ===
git checkout develop
git pull origin develop  # Gets the merged feature changes

# Create feature branch for version bump
git checkout -b feature/bump-v1.1.0

# Bump the version using script
./scripts/version-manager.sh bump backend minor  # 1.0.0 → 1.1.0

# Commit and push the version bump
git add .
git commit -m "Bump backend version to v1.1.0"
git push -u origin feature/bump-v1.1.0

# Create PR: feature/bump-v1.1.0 → develop
gh pr create --base develop --title "Bump to v1.1.0" --body "Version bump for v1.1.0"

# After PR merged AND Docker builds verified:
git checkout develop
git pull origin develop
git tag v1.1.0
git push origin --tags

# === PHASE 4: Application Release (INFRA REPO VIA PR) ===
cd ../figure-collector-infra
git checkout develop
git pull origin develop

# Create feature branch for application release
git checkout -b feature/bump-v1.2.0

# Create application release with current service versions
./scripts/version-manager.sh app-release 1.2.0  # App v1.2.0 with backend v1.1.0

git add .
git commit -m "Application release v1.2.0"
git push -u origin feature/bump-v1.2.0

# Create PR: feature/bump-v1.2.0 → develop
gh pr create --base develop --title "Bump to v1.2.0" --body "Application release v1.2.0"

# After PR merged AND Docker builds verified:
git checkout develop
git pull origin develop
git tag v1.2.0
git push origin --tags

# === PHASE 5: Production Release (RELEASE BRANCHES) ===
# Create release branch from develop (after tags applied)
git checkout develop
git pull origin develop
git checkout -b release/1.2.0

# Push release branch
git push -u origin release/1.2.0

# Create PR: release/1.2.0 → main (fast-forward merge)
gh pr create --base main --title "Release v1.2.0" --body "Production release v1.2.0"

# After PR merged to main:
# - GitHub Actions builds production Docker images with version tags
# - Create GitHub release with SBOM, release notes, migration guides
```

## Multi-Version Development Support

### Concurrent Feature Development

```bash
# Developer A: Working on v1.1.0 feature
git checkout develop
git checkout -b feature/user-stats
# ... develop feature ...

# Developer B: Working on v1.2.0 feature  
git checkout develop  # Start from latest
git checkout -b feature/new-auth-system
# ... develop feature ...

# Developer C: Critical v1.0.1 patch needed
git checkout v1.0.0  # Start from production tag
git checkout -b hotfix/security-patch
# ... fix critical bug ...
```

### Different Merge Strategies

```bash
# Feature A merges first:
# feature/user-stats → develop → bump to v1.1.0 → tag v1.1.0

# Feature B merges later:
# feature/new-auth-system → develop → bump to v1.2.0 → tag v1.2.0

# Hotfix goes directly to main:
# hotfix/security-patch → main → bump to v1.0.1 → tag v1.0.1 → merge back to develop
```

## Version Management Commands

### Show Current Versions
```bash
cd figure-collector-infra
./scripts/version-manager.sh show
```

### Bump Individual Service Version
```bash
# Patch version (bug fixes)
./scripts/version-manager.sh bump backend patch

# Minor version (new features)
./scripts/version-manager.sh bump backend minor

# Major version (breaking changes)
./scripts/version-manager.sh bump backend major
```

### Create Application Release
```bash
# Captures current versions of all services
./scripts/version-manager.sh app-release 1.2.0
```

### Sync Environment Files
```bash
# Update .env files with current service versions
./scripts/version-manager.sh sync
```

### Check Version Compatibility
```bash
# Check if current service combination has been tested
./scripts/version-manager.sh check
```

## Multi-Service Coordination

### When Multiple Services Need Updates

```bash
# 1. Backend changes first
cd figure-collector-backend
# ... merge feature → develop → bump → tag v1.1.0 ...

# 2. Frontend changes second  
cd figure-collector-frontend
# ... merge feature → develop → bump → tag v1.0.1 ...

# 3. Application release coordinates them
cd figure-collector-infra
./scripts/version-manager.sh app-release 1.2.0
# Captures: backend v1.1.0, frontend v1.0.1, scraper v1.0.0
```

## Production Release Strategies

### Release Branch Workflow (Required for Protected Branches)
```bash
# Create release branch from develop (after version tags applied)
git checkout develop
git pull origin develop
git checkout -b release/1.2.0

# Push release branch
git push -u origin release/1.2.0

# Create PR: release/1.2.0 → main
gh pr create --base main --title "Release v1.2.0" --body "Production release v1.2.0"

# After PR merged to main:
# - GitHub Actions builds production Docker images
# - Create GitHub release with SBOM/release notes
```

## Branch Strategy

```
main (production)
  ↑
develop (integration)
  ↑
feature/xyz (development)
```

### Version Tagging by Branch
- **main branch**: Production releases (v1.0.0, v1.1.0) - via release branches
- **develop branch**: All service tags and application releases (AFTER PR merge + build verification)
- **feature branches**: Version bumps committed here, but NO tagging (tags applied after merge)

## Environment-Specific Versioning

### Development Environment
```bash
# Can use latest or specific versions
BACKEND_TAG=latest      # or v1.1.0-dev
FRONTEND_TAG=latest     # or v1.0.1-dev
SCRAPER_TAG=latest      # or v1.0.0-dev
VERSION_MANAGER_TAG=latest  # or v1.1.0-dev
INTEGRATION_TESTS_TAG=latest  # or v1.1.0-dev
```

### Test/Staging Environment
```bash
# Use release candidates or specific versions
BACKEND_TAG=v1.1.0
FRONTEND_TAG=v1.0.1
SCRAPER_TAG=v1.0.0
VERSION_MANAGER_TAG=v1.1.0
INTEGRATION_TESTS_TAG=v1.1.0
```

### Production Environment
```bash
# Always use specific stable versions
BACKEND_TAG=v1.1.0
FRONTEND_TAG=v1.0.1
SCRAPER_TAG=v1.0.0
VERSION_MANAGER_TAG=v1.1.0
INTEGRATION_TESTS_TAG=v1.1.0
```

## Independent Service Versioning

### page-scraper (Standalone Service)
```bash
# Scraper is completely independent
cd page-scraper
git checkout develop
# ... make changes ...
./scripts/version-manager.sh bump scraper minor  # Independent versioning
git tag v1.2.0  # Independent of other services
git push origin develop --tags
```

### Comprehensive Service Ecosystem
```bash
# Each service manages its own versioning
# Integration tests coordinate service compatibility
# Version manager validates service version combinations
```

### New Integration Test Service
```bash
# Comprehensive Docker-based integration testing
cd figure-collector-integration-tests
git checkout develop
# ... update test suites ...
./scripts/version-manager.sh bump integration-tests minor
git tag v1.1.0
git push origin develop --tags
```

### SHALLTEAR PROTOCOL
- 5-phase Docker startup
- Cross-service health checks
- Optimized timeout configurations
- Enhanced test infrastructure

### figure-collector services (Coupled)
```bash
# Backend and frontend are often coordinated
# But can still version independently when changes don't affect each other
# Integration tests validate service compatibility
```

## Rollback Strategy

### Service Rollback
```bash
# Rollback to previous service version
cd figure-collector-backend
git checkout v1.0.0  # Previous stable version
# Build and deploy specific version
```

### Application Rollback
```bash
# Rollback entire application to previous tested combination
cd figure-collector-infra
git checkout v1.1.0  # Previous app version
./deploy.sh prod      # Deploys with previous service versions
```

## Troubleshooting Commands

### Check Current State
```bash
# Show all versions
./scripts/version-manager.sh show

# Check what would be deployed
./scripts/version-manager.sh check

# Sync environment files if needed
./scripts/version-manager.sh sync
```

### Fix Version Conflicts
```bash
# Reset to known good state
git checkout v1.0.0
./scripts/version-manager.sh sync

# Or fix specific service version
./scripts/version-manager.sh bump backend patch
```

## Best Practices Checklist

### DO ✅
- Use semantic versioning consistently
- Create PRs for ALL version bumps (develop is protected)
- Tag AFTER PR merge AND Docker build verification
- Test version compatibility before production
- Document breaking changes in commit messages
- Use specific versions in production environment
- Keep scraper service versioning independent
- Use release branches for merging develop → main

### DON'T ❌
- Push directly to develop (it's protected - use PRs)
- Tag before PR merge or build verification
- Use `latest` tags in production
- Skip integration testing of version combinations
- Make breaking changes in minor versions
- Deploy untested service version combinations
- Force version bumps without actual changes

## Date Formats

- **Version files**: DD-MMM-YYYY (e.g., "08-Jan-2025")
- **Git commits**: Standard git format
- **React app display**: "v1.0.0 • 08-Jan-2025"

## Future Considerations

### As the system grows:
- Consider automated version bumping in CI/CD
- Implement automated compatibility testing
- Add service mesh for version routing
- Expand to full independent service versioning if needed