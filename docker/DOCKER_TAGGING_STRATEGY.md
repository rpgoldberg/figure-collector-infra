# Docker Image Tagging Strategy

## Overview
This document defines the Docker image tagging strategy for the Figure Collector Services.

## Tag Format

### Production Tags
- `latest` - Latest stable release
- `v1.2.3` - Semantic version tags
- `1.2` - Major.minor tags (latest patch)
- `1` - Major version tags (latest minor.patch)

### Development Tags
- `develop` - Latest development branch
- `feature-<name>` - Feature branch builds
- `nightly` - Automated nightly builds
- `snapshot` - Current development snapshot

### Release Candidates
- `rc-1.2.3` - Release candidate versions
- `beta-1.2.3` - Beta releases
- `alpha-1.2.3` - Alpha releases

### Build-specific Tags
- `<branch>-<sha>` - Branch name with commit SHA
- `<date>-<sha>` - Build date with commit SHA (YYYYMMDD-HHmmss-sha)
- `build-<number>` - CI build number

## Tagging Examples

```bash
# Production release
docker tag figure-collector-backend:build ghcr.io/yourorg/figure-collector-backend:v1.2.3
docker tag figure-collector-backend:build ghcr.io/yourorg/figure-collector-backend:1.2
docker tag figure-collector-backend:build ghcr.io/yourorg/figure-collector-backend:1
docker tag figure-collector-backend:build ghcr.io/yourorg/figure-collector-backend:latest

# Development snapshot
docker tag figure-collector-backend:build ghcr.io/yourorg/figure-collector-backend:snapshot
docker tag figure-collector-backend:build ghcr.io/yourorg/figure-collector-backend:develop-abc123f

# Release candidate
docker tag figure-collector-backend:build ghcr.io/yourorg/figure-collector-backend:rc-1.2.3
```

## Lifecycle Management

### Retention Policy
- **Production tags**: Keep indefinitely
- **Release candidates**: Keep for 90 days after release
- **Feature branches**: Keep for 30 days after merge
- **Nightly builds**: Keep last 30 builds
- **Snapshot builds**: Keep last 10 builds

### Promotion Path
1. `feature-*` → `develop`
2. `develop` → `rc-*`
3. `rc-*` → `v*.*.*` + `latest`

## Integration Test Strategy

### Using Pre-built Images
Integration tests will use specifically tagged images:
- **CI/CD Pipeline**: Uses `<branch>-<sha>` tags
- **Local Development**: Uses `develop` or `snapshot` tags
- **Production Testing**: Uses `rc-*` tags

### Docker Compose Override
```yaml
# docker-compose.override.yml for integration tests
version: '3.8'
services:
  backend:
    image: ghcr.io/yourorg/figure-collector-backend:${BACKEND_TAG:-develop}
  frontend:
    image: ghcr.io/yourorg/figure-collector-frontend:${FRONTEND_TAG:-develop}
  scraper:
    image: ghcr.io/yourorg/figure-collector-scraper:${SCRAPER_TAG:-develop}
  version-manager:
    image: ghcr.io/yourorg/figure-collector-version:${VERSION_TAG:-develop}
```

## Automated Tagging Script

```bash
#!/bin/bash
# tag-images.sh

VERSION=$1
REGISTRY="ghcr.io/yourorg"

if [[ -z "$VERSION" ]]; then
  echo "Usage: ./tag-images.sh <version>"
  exit 1
fi

SERVICES=("backend" "frontend" "page-scraper" "version-manager")

for SERVICE in "${SERVICES[@]}"; do
  IMAGE_NAME="figure-collector-${SERVICE}"
  
  # Tag with full version
  docker tag ${IMAGE_NAME}:build ${REGISTRY}/${IMAGE_NAME}:v${VERSION}
  
  # Tag with major.minor
  MAJOR_MINOR=$(echo $VERSION | cut -d. -f1,2)
  docker tag ${IMAGE_NAME}:build ${REGISTRY}/${IMAGE_NAME}:${MAJOR_MINOR}
  
  # Tag with major
  MAJOR=$(echo $VERSION | cut -d. -f1)
  docker tag ${IMAGE_NAME}:build ${REGISTRY}/${IMAGE_NAME}:${MAJOR}
  
  # Tag as latest if it's a production release
  if [[ ! "$VERSION" =~ (alpha|beta|rc) ]]; then
    docker tag ${IMAGE_NAME}:build ${REGISTRY}/${IMAGE_NAME}:latest
  fi
  
  # Push all tags
  docker push ${REGISTRY}/${IMAGE_NAME} --all-tags
done
```

## Security Considerations

### Image Signing
- All production images must be signed with cosign
- Signature verification required for production deployments

### Vulnerability Scanning
- Images scanned on every push
- Production deployments blocked if HIGH/CRITICAL vulnerabilities found
- Scan results stored for 90 days

## Deployment Matrix

| Environment | Tag Pattern | Update Frequency | Rollback Strategy |
|------------|-------------|------------------|-------------------|
| Production | `v*.*.*`, `latest` | On release | Previous version tag |
| Staging | `rc-*.*.*` | On RC build | Previous RC |
| Development | `develop`, `snapshot` | On commit | Previous snapshot |
| Feature Test | `feature-*` | On push | Commit SHA |