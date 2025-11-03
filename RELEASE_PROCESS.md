# Figure Collector Services Release Process

## Overview
This document outlines the complete release process for Figure Collector Services, including all deployable services and their versioning strategy.

## Service Versions

| Service | Current Release | Port | Deployable |
|---------|-----------------|------|------------|
| figure-collector-backend | 2.0.0 | 5000 | ✅ |
| figure-collector-frontend | 2.0.0 | 3000 | ✅ |
| page-scraper | 2.0.0 | 3005 | ✅ |
| version-manager | 1.1.0 | 3001/3011 | ✅ |
| figure-collector-integration-tests | N/A | N/A | ❌ Test Runner |
| figure-collector-infra | N/A | N/A | ❌ CI/CD Tools |

## Release Process Phases

### Phase 1: Pre-Release Preparation
1. **Security Review**
   ```bash
   # Scan current images for vulnerabilities
   docker run --rm aquasec/trivy image ghcr.io/rpgoldberg/[service]:test-[version] --severity HIGH,CRITICAL
   ```
   - Address all HIGH/CRITICAL vulnerabilities
   - Update dependencies as needed
   - Run tests after fixes

2. **Branch Preparation**
   ```bash
   # Ensure on release branch
   git checkout release/[version]

   # Pull latest security updates from develop if needed
   git merge develop --no-ff
   ```

### Phase 2: Create Pull Requests
For each service in order:
1. version-manager (first - manages compatibility)
2. Backend, Frontend, Scraper (parallel possible)

```bash
# Create PR via GitHub CLI
gh pr create \
  --base develop \
  --head release/[version] \
  --title "Release [service] v[version]" \
  --body "Release notes..."
```

### Phase 3: Develop Branch Merge
1. **Review PR Checks**
   - CI tests pass
   - Security scanning complete
   - Code review approved

2. **Merge to Develop**
   ```bash
   # Merge PR (from GitHub UI or CLI)
   gh pr merge [PR-number] --merge
   ```

3. **Validate Integration**
   ```bash
   cd figure-collector-integration-tests
   ./run-with-prebuilt.sh
   # Expect: 133/133 tests passing
   ```

### Phase 4: Service Version Tagging on Develop

After successful develop validation and before creating release branches:

```bash
# In EACH service repository (all 6)
git checkout develop
git pull origin develop

# Service-specific version tag (varies per service)
git tag -a v[version] -m "Release [service] v[version]"
git push origin v[version]
```

**Service Tags (on develop):**
- Backend: `v2.0.1`
- Frontend: `v2.0.1`
- Scraper: `v2.0.1`
- Version Manager: `v1.1.1` (independent versioning)
- Integration Tests: `v1.0.1`
- Infrastructure: `v2.0.1`

### Phase 5: Release Branch Creation

After tagging on develop:

```bash
# In EACH service repository
git checkout develop
git checkout -b release/v[version]
git push -u origin release/v[version]
```

Creates release branches:
- `release/v2.0.1` for Backend, Frontend, Scraper, Infrastructure
- `release/v1.1.1` for Version Manager
- `release/v1.0.1` for Integration Tests

### Phase 6: Production Promotion

1. **Create Release PRs to Main**
   ```bash
   # In each service repository
   gh pr create \
     --base main \
     --head release/v[version] \
     --title "Release v[version]" \
     --body "Production release with security scanning and SBOM"
   ```

2. **Merge Release PRs**
   - Review all checks passing
   - Merge to main (triggers production builds)
   - Builds production Docker images with service version tags

### Phase 7: Application Version Tagging

After ALL release PRs merged to main and production builds verified:

```bash
# In EACH service repository (all 6)
git checkout main
git pull origin main

# Application version tag (SAME across all repos)
git tag -a v[version]-application -m "Application Release v[version]"
git push origin v[version]-application
```

**Why Application Tags:**
- Marks a verified, coordinated release of ALL services together
- Triggers Docker images with application tag (e.g., `2.0.1-application`)
- Enables single-version deployment across all services

**Example:**
```yaml
# docker-compose.yml using application tags
services:
  backend: ghcr.io/rpgoldberg/figure-collector-backend:2.0.1-application
  frontend: ghcr.io/rpgoldberg/figure-collector-frontend:2.0.1-application
  scraper: ghcr.io/rpgoldberg/page-scraper:2.0.1-application
  version-manager: ghcr.io/rpgoldberg/version-manager:2.0.1-application
```

**Tag Naming Conventions:**
- **Service tags**: `v2.0.1`, `v1.1.1`, `v1.0.1` (independent versions on develop)
- **Application tag**: `v2.0.1-application` (coordinated release on main, all 6 repos)

### Phase 8: GitHub Release Creation

```bash
# Create GitHub release
gh release create v[version] \
  --title "Release v[version]" \
  --notes "See CHANGELOG.md" \
  --target main
```

Attach artifacts:
- SBOM files (generated during build)
- Release notes
- Migration guides

## Rollback Procedures

### Hotfix Process (Critical Issues)
```bash
# Create hotfix from main
git checkout -b hotfix/[issue] main

# Fix issue, test thoroughly
# ...

# Merge to main (emergency)
git checkout main
git merge --no-ff hotfix/[issue]
git tag v[version].1

# Backport to develop
git checkout develop
git merge --no-ff hotfix/[issue]
```

## CI/CD Pipeline

### On Pull Request
- Build Docker image (no push)
- Run security scanning
- Execute test suite
- Generate SBOM

### On Develop Merge
- Build and push image with `develop` tag
- Full security scan with issue creation
- Integration test validation

### On Main Merge
- Build and push with version tag + `latest`
- Production security scanning
- Create GitHub release

## Monitoring Post-Release

### Automated Monitoring
- Daily security scans (2 AM UTC)
- Weekly comprehensive scans (Sunday 3 AM UTC)
- Dependabot for dependency updates

### Manual Checks
```bash
# Verify deployed versions
curl http://[service-url]/health

# Check container logs
docker logs [container-name]

# Monitor GitHub Security tab
```

## Environment Variables

### Required Secrets in GitHub
- `GITHUB_TOKEN` - Auto-provided
- `DISCORD_WEBHOOK` - For security notifications
- `SONAR_TOKEN` - Code quality scanning (optional)

### Image Tag Configuration
```yaml
BACKEND_TAG: test-2.0.0
FRONTEND_TAG: test-2.0.0
SCRAPER_TAG: test-2.0.0
VERSION_MANAGER_TAG: test-1.1.0
```

## Troubleshooting

### Common Issues

1. **Vulnerability Found After PR**
   - Add fix commit to release branch
   - PR automatically updates

2. **Integration Tests Fail**
   - Check service connectivity
   - Verify environment variables
   - Review recent changes

3. **Docker Build Fails**
   - Check base image availability
   - Verify build context
   - Review Dockerfile changes

## Release Checklist

### Pre-Release
- [ ] All HIGH/CRITICAL vulnerabilities addressed
- [ ] Unit tests passing (100%)
- [ ] Integration tests passing (133/133)
- [ ] Security scanning complete
- [ ] Version bumps PR'd to develop and merged

### Develop Branch
- [ ] Service version tags created (all 6 repos)
- [ ] Release branches created (all 6 repos)
- [ ] Docker images with `develop` tag verified

### Main Branch
- [ ] Release PRs created (all 6 repos)
- [ ] Release PRs reviewed and merged
- [ ] Production Docker images built successfully
- [ ] Service version tags on main (v2.0.1, v1.1.1, v1.0.1)
- [ ] **Application version tags on ALL 6 repos** (v2.0.1-application)
- [ ] Docker images with application tags verified

### Post-Release
- [ ] GitHub releases published (all 6 repos)
- [ ] SBOM artifacts attached to releases
- [ ] Discord notifications configured
- [ ] Post-release monitoring active
- [ ] Version registry (version.json) updated

## Docker Tagging Strategy

### Tag Naming Conventions

**Git Tags** (in repositories):
- Have `v` prefix: `v2.0.1`, `v2.0.1-application`, `v1.1.1`
- Used to trigger GitHub Actions workflows

**Docker Tags** (in GHCR):
- NO `v` prefix: `2.0.1`, `2.0.1-application`, `1.1.1`
- Generated automatically by `docker/metadata-action`

### Dual-Tagging for Application Releases

When you push a git tag with `-application` suffix, the Docker workflow automatically generates **BOTH** tags pointing to the **SAME image digest**:

```bash
# Push git tag with -application suffix
git push origin v2.0.1-application

# GitHub Actions automatically generates BOTH Docker tags:
# ✅ ghcr.io/[repo]:2.0.1-application  (application release)
# ✅ ghcr.io/[repo]:2.0.1              (service version)
# ⭐ Both point to the EXACT SAME image digest
```

### Workflow Configuration

The `docker-publish.yml` workflow dynamically reads service versions and uses tag patterns to generate Docker tags.

**Version Source Files:**
- **Version Manager**: Reads from `version.json` → `services['version-manager'].version`
- **Backend/Frontend/Scraper**: Read from `package.json` → `.version`

**Tag Generation Patterns:**

```yaml
# Step 1: Read service version dynamically
- name: Read service version from package.json   # (or version.json for version-manager)
  id: service-version
  run: |
    SERVICE_VERSION=$(node -pe "require('./package.json').version")  # or version.json
    echo "version=$SERVICE_VERSION" >> $GITHUB_OUTPUT

# Step 2: Generate Docker tags based on git tag
tags: |
  # Service version tag (from package.json or version.json)
  # Only enabled when git tag contains -application suffix
  type=raw,value=${{ steps.service-version.outputs.version }},enable=${{ contains(github.ref, '-application') }}

  # Application version tag (v2.0.1-application -> 2.0.1-application)
  # Extracts version and preserves -application suffix
  type=match,pattern=v(.+)-application,group=1,suffix=-application
```

**How It Works:**
1. Push git tag `v2.0.1-application` to any service
2. Workflow reads service version from its version file (package.json or version.json)
3. **Both Docker tags** are created in the SAME build:
   - `2.0.1` (from service version file)
   - `2.0.1-application` (from git tag pattern)
4. Both tags point to the EXACT SAME digest

### Tag Generation Examples

| Git Tag Push | Docker Tags Generated | Use Case |
|--------------|----------------------|----------|
| `v2.0.1` | `2.0.1` | Independent service version |
| `v2.0.1-application` | `2.0.1-application` AND `2.0.1` | Coordinated application release |
| `v1.1.1` | `1.1.1` | Version manager service version |

### Deployment Flexibility

Since the same image has multiple tags, you can deploy using either:

```yaml
# Using service version (specific to each service)
services:
  backend:
    image: ghcr.io/rpgoldberg/figure-collector-backend:2.0.1

# Using application version (coordinated across all services)
services:
  backend:
    image: ghcr.io/rpgoldberg/figure-collector-backend:2.0.1-application

# Both pull the EXACT SAME image (same SHA256 digest)
```

### Why This Matters

- **Same Image Digest**: No risk of slight variations between builds
- **Deployment Flexibility**: Use service or application tags as needed
- **Efficient Storage**: Docker registries store layers only once
- **Clear Coordination**: Application tags mark verified, coordinated releases
- **Decoupled Versioning**: Each service maintains its version independently (in package.json or version.json) while coordinated releases use application tags

## Docker Tagging Strategy

### Tag Naming Conventions

**Git Tags** (in repositories):
- Have `v` prefix: `v2.0.1`, `v2.0.1-application`, `v1.1.1`
- Used to trigger GitHub Actions workflows

**Docker Tags** (in GHCR):
- NO `v` prefix: `2.0.1`, `2.0.1-application`, `1.1.1`
- Generated automatically by `docker/metadata-action`

### Dual-Tagging for Application Releases

When you push a git tag with `-application` suffix, the Docker workflow automatically generates **BOTH** tags pointing to the **SAME image digest**:

```bash
# Push git tag with -application suffix
git push origin v2.0.1-application

# GitHub Actions automatically generates BOTH Docker tags:
# ✅ ghcr.io/[repo]:2.0.1-application  (application release)
# ✅ ghcr.io/[repo]:2.0.1              (service version)
# ⭐ Both point to the EXACT SAME image digest
```

### Workflow Configuration

The `docker-publish.yml` workflow dynamically reads service versions and uses tag patterns to generate Docker tags.

**Version Source Files:**
- **Version Manager**: Reads from `version.json` → `services['version-manager'].version`
- **Backend/Frontend/Scraper**: Read from `package.json` → `.version`

**Tag Generation Patterns:**

```yaml
# Step 1: Read service version dynamically
- name: Read service version from package.json   # (or version.json for version-manager)
  id: service-version
  run: |
    SERVICE_VERSION=$(node -pe "require('./package.json').version")  # or version.json
    echo "version=$SERVICE_VERSION" >> $GITHUB_OUTPUT

# Step 2: Generate Docker tags based on git tag
tags: |
  # Service version tag (from package.json or version.json)
  # Only enabled when git tag contains -application suffix
  type=raw,value=${{ steps.service-version.outputs.version }},enable=${{ contains(github.ref, '-application') }}

  # Application version tag (v2.0.1-application -> 2.0.1-application)
  # Extracts version and preserves -application suffix
  type=match,pattern=v(.+)-application,group=1,suffix=-application
```

**How It Works:**
1. Push git tag `v2.0.1-application` to any service
2. Workflow reads service version from its version file (package.json or version.json)
3. **Both Docker tags** are created in the SAME build:
   - `2.0.1` (from service version file)
   - `2.0.1-application` (from git tag pattern)
4. Both tags point to the EXACT SAME digest

### Tag Generation Examples

| Git Tag Push | Docker Tags Generated | Use Case |
|--------------|----------------------|----------|
| `v2.0.1` | `2.0.1` | Independent service version |
| `v2.0.1-application` | `2.0.1-application` AND `2.0.1` | Coordinated application release |
| `v1.1.1` | `1.1.1` | Version manager service version |

### Deployment Flexibility

Since the same image has multiple tags, you can deploy using either:

```yaml
# Using service version (specific to each service)
services:
  backend:
    image: ghcr.io/rpgoldberg/figure-collector-backend:2.0.1

# Using application version (coordinated across all services)
services:
  backend:
    image: ghcr.io/rpgoldberg/figure-collector-backend:2.0.1-application

# Both pull the EXACT SAME image (same SHA256 digest)
```

### Why This Matters

- **Same Image Digest**: No risk of slight variations between builds
- **Deployment Flexibility**: Use service or application tags as needed
- **Efficient Storage**: Docker registries store layers only once
- **Clear Coordination**: Application tags mark verified, coordinated releases
- **Decoupled Versioning**: Each service maintains its version independently (in package.json or version.json) while coordinated releases use application tags

## Version History

| Release | Date | Major Changes |
|---------|------|---------------|
| 2.0.1 | 2025-10-27 | Fixed Docker dual-tagging strategy, enhanced release documentation |
| 2.0.0 | TBD | Security scanning, SBOM generation, comprehensive testing |
| 1.1.0 | Previous | Version manager updates |

## Contact

For release issues or questions, create an issue in the figure-collector-infra repository.