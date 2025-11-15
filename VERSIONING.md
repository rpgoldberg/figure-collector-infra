# Figure Collector Services - Versioning Strategy

## Overview

Each service maintains its own independent version in `package.json`. The application version is set via environment variable for coordinated releases.

## Semantic Versioning

All services follow [Semantic Versioning 2.0.0](https://semver.org/):

### Version Format: `MAJOR.MINOR.PATCH`

- **MAJOR** (X.0.0): Breaking changes, incompatible API changes
- **MINOR** (1.X.0): New features, backward-compatible
- **PATCH** (1.0.X): Bug fixes, backward-compatible

## Service Versioning

### Each Service Owns Its Version

**Services version independently:**
- backend/package.json
- frontend/package.json
- scraper/package.json
- infrastructure/package.json (docs only, no code)

**Update version manually in package.json:**
```json
{
  "name": "figure-collector-backend",
  "version": "2.1.0"
}
```

### When to Bump Versions

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| Bug fix | PATCH | 2.0.0 → 2.0.1 |
| New feature (compatible) | MINOR | 2.0.0 → 2.1.0 |
| Breaking change | MAJOR | 2.0.0 → 3.0.0 |

## Application Versioning

**Application version** represents coordinated releases across services.

### Set in docker-compose.yml

```yaml
services:
  backend:
    environment:
      - APP_VERSION=2.1.0
      - APP_RELEASE_DATE=15-Nov-2025
```

### When to Update Application Version

Update when doing a **coordinated release** (multiple services):
- Backend v2.1.0 + Frontend v2.1.0 = **Application v2.1.0**

For single-service releases, **no application version change needed**:
- Just scraper v2.0.4 = Application version stays 2.1.0

## Release Workflow

### 1. Single Service Release

```bash
# In service directory
git checkout -b feature/my-feature

# Implement feature with tests
npm test

# Bump version in package.json manually
# Edit package.json: "version": "2.1.0"

git add package.json
git commit -m "Add my feature"
git push -u origin feature/my-feature
gh pr create --base develop
```

### 2. Coordinated Release (Multiple Services)

```bash
# Bump each affected service's package.json
# backend/package.json: 2.0.2 → 2.1.0
# frontend/package.json: 2.0.2 → 2.1.0

# Update application version in infrastructure repo
# docker-compose.yml: APP_VERSION=2.1.0

# Merge all service PRs to develop
# Test develop branch
# Create release branches from develop
# Tag release in infrastructure repo
git tag -a v2.1.0 -m "Application Release v2.1.0"
```

## Version Display

Services expose their version via `/health` endpoint:

```javascript
// Each service
app.get('/health', (req, res) => {
  res.json({
    service: 'backend',
    version: require('./package.json').version,
    status: 'healthy'
  });
});
```

Backend aggregates and serves `/version` for the frontend:

```javascript
app.get('/version', async (req, res) => {
  res.json({
    application: {
      version: process.env.APP_VERSION,
      releaseDate: process.env.APP_RELEASE_DATE
    },
    services: {
      backend: { version: require('./package.json').version },
      // ... aggregate from other services' /health endpoints
    }
  });
});
```

## Breaking Changes

When making breaking changes:

1. **Bump MAJOR version** (e.g., 2.1.0 → 3.0.0)
2. **Document breaking changes** in PR description
3. **Update dependent services** in same release
4. **Consider API versioning** (/api/v1/, /api/v2/) for gradual migration

## Migration from Old System

**What changed:**
- ❌ Removed: version-manager service
- ❌ Removed: version.json file
- ❌ Removed: Bump scripts
- ❌ Removed: Service registration

**New approach:**
- ✅ Manual version bumps in package.json
- ✅ Application version in docker-compose.yml environment
- ✅ Self-reporting via /health endpoints
- ✅ Simple, transparent, reviewable

## Best Practices

### Always Bump Version in PR (Before Merge)
```bash
# ✅ Good: Version bump IN the PR
feature/add-search → develop
  - Add search feature
  - package.json: "version": "2.1.0"

# ❌ Bad: Version bump after merge
feature/add-search → develop (version still 2.0.2)
  → Then commit to develop to bump version
```

### Use Conventional Commits (Optional)
```bash
feat: add Atlas Search support  # → MINOR bump
fix: correct authentication bug  # → PATCH bump
feat!: redesign API endpoints   # → MAJOR bump
```

### Tag Releases in Git
```bash
# Service tags
git tag -a backend-v2.1.0 -m "Backend v2.1.0"

# Application tags (in infrastructure repo)
git tag -a v2.1.0 -m "Application v2.1.0"
```

## Troubleshooting

### Version not showing in UI
- Check `/version` endpoint returns data
- Check APP_VERSION environment variable is set
- Check backend is aggregating from services correctly

### Service shows wrong version
- Check package.json has correct version
- Check service was rebuilt after version change
- Check Docker image tag matches version
