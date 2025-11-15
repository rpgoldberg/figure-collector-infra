# Git Flow & Versioning Workflow

## Overview

Git flow and versioning workflow for Figure Collector microservices.

## Repository Structure

- `figure-collector-backend/` - Backend service
- `figure-collector-frontend/` - Frontend service
- `page-scraper/` - Scraping service
- `figure-collector-integration-tests/` - Integration tests
- `figure-collector-infra/` - Infrastructure and orchestration

## Core Principles

1. ✅ **Develop branch is protected** - All changes require PRs
2. ✅ **Version bumps IN the PR** - Before merging to develop
3. ✅ **Test develop before release** - Docker images must pass tests
4. ✅ **Tag after merge to main** - Production releases only
5. ✅ **Services version independently** - Each has own package.json

## Complete Workflow

### 1. Feature Development

```bash
# Start from develop
cd figure-collector-backend
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/add-user-stats

# Implement feature with tests
# ... code ...

# Bump version in package.json manually
# Edit package.json: "version": "2.1.0"

# Commit all changes INCLUDING version bump
git add .
git commit -m "Add user stats API endpoint"
git push -u origin feature/add-user-stats
```

### 2. Create PR

```bash
# Create PR to develop (version bump included)
gh pr create --base develop --title "Add user stats endpoint" --body "
## Changes
- New /api/stats endpoint
- Version bump: 2.0.2 → 2.1.0

## Testing
- Added unit tests
- Added integration tests
- Coverage: 92%
"
```

### 3. Review and Merge

```bash
# After approval, squash and merge
# This keeps develop history clean
```

### 4. Test Develop Branch

```bash
# After merge, Docker builds trigger automatically
# Test the new Docker images on develop branch
# Verify functionality works as expected
```

### 5. Create Release

```bash
# After testing passes, create release branch
git checkout develop
git pull origin develop
git checkout -b release/v2.1.0

# Create PR to main
gh pr create --base main --title "Release v2.1.0" --body "
## Release Notes
- Backend v2.1.0: User stats API
- Frontend v2.1.0: Dark mode support

## Testing
- Develop branch tested ✓
- All services healthy ✓
"
```

### 6. Tag Release

```bash
# After merge to main
git checkout main
git pull origin main

# Tag the release
git tag -a v2.1.0 -m "Application Release v2.1.0"
git push origin v2.1.0

# Also tag individual services if needed
git tag -a backend-v2.1.0 -m "Backend v2.1.0"
git push origin backend-v2.1.0
```

## Branch Strategy

### Branch Types

```
main (production)
  ↑
release/v2.1.0 ← PR from develop
  ↑
develop (integration)
  ↑
feature/add-stats ← Feature branches
```

### Branch Rules

- **main**: Production releases only, protected
- **develop**: Integration branch, protected, requires PRs
- **feature/***: Feature development
- **release/***: Release preparation
- **hotfix/***: Emergency production fixes

## Coordinated Releases (Multiple Services)

When releasing multiple services together:

### 1. Prepare All Service PRs

```bash
# Backend PR
cd figure-collector-backend
git checkout -b feature/atlas-search
# ... implement ...
# Edit package.json: "version": "2.1.0"
gh pr create --base develop

# Frontend PR
cd ../figure-collector-frontend
git checkout -b feature/dark-mode
# ... implement ...
# Edit package.json: "version": "2.1.0"
gh pr create --base develop

# Infrastructure PR (update APP_VERSION)
cd ../figure-collector-infra
git checkout -b release/v2.1.0-prep
# Edit docker-compose.yml: APP_VERSION=2.1.0
gh pr create --base develop
```

### 2. Merge All PRs

```bash
# Merge all service PRs to develop
# Wait for Docker builds to complete
```

### 3. Test Develop

```bash
# Test all services together on develop branch
# Verify integration works
# Check version display in UI
```

### 4. Create Release

```bash
# Create release branch in infrastructure
cd figure-collector-infra
git checkout develop
git pull
git checkout -b release/v2.1.0
gh pr create --base main --title "Release v2.1.0"

# After merge, tag it
git checkout main
git pull
git tag -a v2.1.0 -m "Release v2.1.0"
git push origin v2.1.0
```

## Hotfix Workflow

For urgent production fixes:

```bash
# Create hotfix branch from main
git checkout main
git pull
git checkout -b hotfix/security-patch

# Fix the issue
# ... code ...

# Bump PATCH version
# Edit package.json: "2.1.0" → "2.1.1"

git add .
git commit -m "Fix security vulnerability"
git push -u origin hotfix/security-patch

# Create PRs to BOTH main and develop
gh pr create --base main --title "Hotfix: Security patch"
gh pr create --base develop --title "Hotfix: Security patch"

# After merge to main, tag it
git checkout main
git pull
git tag -a v2.1.1 -m "Hotfix v2.1.1"
git push origin v2.1.1
```

## Best Practices

### Version Bumps

✅ **Do:**
- Bump version in package.json IN the feature PR
- Follow semantic versioning (major.minor.patch)
- Include version bump in PR title

❌ **Don't:**
- Merge PR first, then bump version in separate commit
- Forget to bump version before merge
- Commit directly to develop

### Commit Messages

✅ **Good:**
```bash
git commit -m "Add user stats API endpoint"
git commit -m "Fix authentication token expiry"
git commit -m "Update dark mode styling"
```

❌ **Bad:**
```bash
git commit -m "stuff"
git commit -m "fixed it"
git commit -m "WIP"
```

### PR Strategy

✅ **Use Draft PRs for WIP:**
```bash
gh pr create --draft --title "WIP: Add feature"
# Push multiple commits to fix CI
# Squash commits when ready
gh pr ready
```

✅ **Squash and Merge:**
- Keeps develop history clean
- One commit per feature
- Easy to revert if needed

## Troubleshooting

### PR Checks Failing

1. **Run CI checks locally first:**
   ```bash
   make ci-local  # Runs same checks as GitHub Actions
   ```

2. **Fix issues in draft PR:**
   ```bash
   gh pr create --draft
   # Push fixes
   # Squash when green
   gh pr ready
   ```

### Version Conflicts

If multiple PRs bump the same version:
1. First PR wins
2. Second PR must resolve conflict and bump higher
3. Communicate with team

### Forgot Version Bump

If PR merged without version bump:
1. Create new PR with version bump
2. Document the mistake
3. Don't commit directly to develop

## Migration Notes

**Old system (removed):**
- ❌ version-manager service
- ❌ version.json file
- ❌ Bump scripts
- ❌ Service registration

**New system:**
- ✅ Manual version bumps in package.json
- ✅ Git workflow handles versioning
- ✅ Simple and transparent
