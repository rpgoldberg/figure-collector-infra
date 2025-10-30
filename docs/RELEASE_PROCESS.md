# Release Process - Figure Collector Services

## Overview
This document describes the simplified release process for the Figure Collector monorepo services.

**Key Principle**: One source of truth - `package.json` in each service.

## Version Strategy

### Service Versioning
Each service maintains its own version in `package.json` following [Semantic Versioning](https://semver.org/):
- **Major** (X.0.0): Breaking changes
- **Minor** (x.Y.0): New features (backward compatible)
- **Patch** (x.y.Z): Bug fixes

### Application Versioning
Coordinated releases across all services use application versions tracked in `figure-collector-infra/application-versions.json` for reference purposes only.

## Release Workflow

### 1. Version Bump (in `develop` branch)

```bash
# On service's develop branch
cd [service-directory]

# Update package.json
npm version patch  # or minor, or major

# Or manually edit package.json
# "version": "2.0.3"

# Commit
git add package.json package-lock.json
git commit -m "Bump to vX.Y.Z"
```

### 2. Create Release PR (develop → main)

```bash
# Push changes
git push origin develop

# Create PR via GitHub CLI
gh pr create \
  --base main \
  --head develop \
  --title "Release vX.Y.Z" \
  --body "Release version X.Y.Z

## Changes
- [List key changes]

## Testing
- [ ] All tests pass
- [ ] Integration tests pass
- [ ] Docker build succeeds"
```

**Or create PR via GitHub UI:**
- Base: `main`
- Compare: `develop`  
- Title: `Release vX.Y.Z`

### 3. Review & Merge

**Review checklist:**
- [ ] Version in `package.json` is correct
- [ ] All CI checks pass (build, tests, security scans)
- [ ] No merge conflicts
- [ ] CHANGELOG updated (if applicable)

**Merge to main** (protected branch requires PR approval)

### 4. Tag Source Code

**Immediately after merge to main:**

```bash
# Pull latest main
git checkout main
git pull origin main

# Create tags
SERVICE_VERSION=$(node -pe "require('./package.json').version")
git tag v$SERVICE_VERSION
git tag -a v$SERVICE_VERSION-application -m "Release v$SERVICE_VERSION application"

# Push tags
git push origin v$SERVICE_VERSION v$SERVICE_VERSION-application
```

**Tag meanings:**
- `vX.Y.Z`: Service version tag (matches package.json)
- `vX.Y.Z-application`: Application coordination tag (for multi-service releases)

### 5. Docker Build (Automatic)

**GitHub Actions automatically:**
1. Detects push to `main` branch
2. Reads service version from `package.json`
3. Builds Docker image
4. Tags image with service version: `ghcr.io/rpgoldberg/[service]:X.Y.Z`
5. Tags image with `latest` (for main branch)
6. Pushes to GitHub Container Registry
7. Runs security scans (Trivy, Grype)
8. Generates SBOM artifacts

**No manual Docker operations needed.**

### 6. Sync Branches

```bash
# Fast-forward develop to match main
git checkout develop
git merge main --ff-only
git push origin develop
```

**Result**: `develop` and `main` are at the same commit (tagged).

## Multi-Service (Application) Releases

When coordinating a release across multiple services:

### Planning
1. Create tracking issue in `figure-collector-infra`
2. List all services and target versions
3. Document dependencies and order

### Execution
1. Release each service individually (follow steps 1-6 above)
2. Use same application version suffix for all services (e.g., `-application`)
3. Update `figure-collector-infra/application-versions.json`:
   ```json
   {
     "application": "2.0.2",
     "services": {
       "backend": "2.0.2",
       "frontend": "2.0.2",
       "scraper": "2.0.2",
       "version-manager": "1.1.2",
       "integration-tests": "1.0.2"
     },
     "released": "2025-10-30"
   }
   ```

### Integration Testing
```bash
cd figure-collector-integration-tests
docker-compose -f docker-compose.test.yml up --abort-on-container-exit
```

## Branch Protection Rules

### `main` branch
- ✅ Require pull request before merging
- ✅ Require status checks to pass
- ✅ Require conversation resolution
- ❌ Do not allow force pushes

### `develop` branch  
- ✅ Require pull request before merging
- ✅ Require status checks to pass
- ❌ Do not allow force pushes

## Docker Image Tags

**Automatic tags on main branch push:**
- `X.Y.Z` (service version from package.json)
- `latest` (always points to latest main)

**Automatic tags on develop branch push:**
- `develop` (always points to latest develop)

**Automatic tags on PR:**
- `pr-###` (for testing PR builds)

## Hotfix Process

For urgent fixes that need to bypass normal workflow:

```bash
# Create hotfix branch from main
git checkout main
git pull
git checkout -b hotfix/vX.Y.Z

# Make fix
# ... edit files ...

# Bump version (patch)
npm version patch

# Commit and push
git add .
git commit -m "Hotfix: [description]"
git push origin hotfix/vX.Y.Z

# Create PR: hotfix/vX.Y.Z → main
gh pr create --base main --head hotfix/vX.Y.Z \
  --title "Hotfix vX.Y.Z" --label "hotfix"

# After merge: tag and sync develop
# (follow steps 4-6 above)
```

## Rollback Process

### Docker Image Rollback
```bash
# Redeploy previous version
docker pull ghcr.io/rpgoldberg/[service]:X.Y.Z-previous
# Update deployment configuration

# Docker images are immutable - old versions always available
```

### Source Code Rollback
```bash
# Option 1: Revert commit on main
git revert [commit-hash]
git push origin main

# Option 2: Reset tag to previous commit  
git tag -f vX.Y.Z [previous-commit]
git push origin vX.Y.Z --force

# Then rebuild Docker image if needed
```

## Troubleshooting

### PR Merge Blocked
- Check all required status checks are passing
- Resolve any merge conflicts
- Ensure conversations are resolved
- Verify you have approval (if required)

### Docker Build Failed
- Check GitHub Actions logs
- Verify Dockerfile syntax
- Check for missing dependencies in package.json
- Ensure tests pass locally

### Tag Already Exists
```bash
# Force update tag (use with caution)
git tag -f vX.Y.Z [commit-hash]
git push origin vX.Y.Z --force
```

### Version Mismatch
- Ensure package.json version matches intended release
- Check that package-lock.json is synchronized
- Verify no uncommitted changes to package.json

## Best Practices

1. **Always test locally first**: `npm test` and `npm run build`
2. **Keep develop and main synchronized**: Regular merges prevent conflicts
3. **Use semantic versioning correctly**: Breaking changes = major bump
4. **Document changes**: Update CHANGELOG or PR description
5. **Review thoroughly**: Don't merge your own PRs for releases
6. **Tag immediately after merge**: Prevents confusion about release points
7. **Monitor CI/CD**: Watch GitHub Actions to ensure successful deployment

## Reference

- **Semantic Versioning**: https://semver.org/
- **GitHub Flow**: https://guides.github.com/introduction/flow/
- **Docker Tagging Best Practices**: https://docs.docker.com/develop/dev-best-practices/

---

**Last Updated**: 2025-10-30  
**Version**: 1.0.0
