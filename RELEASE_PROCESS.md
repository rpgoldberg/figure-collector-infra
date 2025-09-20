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

### Phase 4: Tagging Strategy

After successful develop validation:

```bash
# Service-specific version tag
git checkout develop
git pull origin develop
git tag -a v[version] -m "Release [service] v[version]"

# System release tag (on backend repo as primary)
git tag -a release-[version] -m "System Release [version]"

# Push tags
git push origin v[version]
git push origin release-[version]
```

**Tag Naming Convention:**
- Service tags: `v2.0.0`, `v1.1.0`
- System release: `release-2.0.0`

### Phase 5: Production Promotion

1. **Create Main Branch PR**
   ```bash
   gh pr create \
     --base main \
     --head develop \
     --title "Production Release v[version]" \
     --body "Promoting tested v[version] to production"
   ```

2. **Merge to Main**
   - Should be fast-forward if develop is stable
   - Triggers production image build with `latest` tag

### Phase 6: GitHub Release Creation

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

- [ ] All HIGH/CRITICAL vulnerabilities addressed
- [ ] Unit tests passing (100%)
- [ ] Integration tests passing (133/133)
- [ ] Security scanning complete
- [ ] Release branches up to date
- [ ] PRs created and reviewed
- [ ] Develop branch validated
- [ ] Version tags created
- [ ] Main branch updated
- [ ] GitHub releases published
- [ ] Discord notifications configured
- [ ] Post-release monitoring active

## Version History

| Release | Date | Major Changes |
|---------|------|---------------|
| 2.0.0 | TBD | Security scanning, SBOM generation, comprehensive testing |
| 1.1.0 | Previous | Version manager updates |

## Contact

For release issues or questions, create an issue in the figure-collector-infra repository.