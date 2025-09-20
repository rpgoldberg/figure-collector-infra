# CI/CD Configuration Guide

## Registry Organization Configuration

This project supports configurable Docker registry organizations to allow for easy forking and customization.

### Default Configuration
- **Registry**: GitHub Container Registry (`ghcr.io`)
- **Default Organization**: `rpgoldberg`
- **Image Naming**: `ghcr.io/{org}/figure-collector-{service}`

### Customization Options

#### 1. For Forks - Update GitHub Actions
When forking this project, the GitHub Actions workflow automatically uses your GitHub username/organization:
```yaml
env:
  REGISTRY_ORG: ${{ github.repository_owner }}  # Automatically uses your GitHub org
```

#### 2. For Manual Docker Builds
When building Docker images manually, you can specify your organization:
```bash
# Build with custom organization
docker build \
  --build-arg GITHUB_ORG=yourorg \
  --build-arg GITHUB_REPO=your-repo \
  -t your-registry/your-image:tag \
  -f Dockerfile.production \
  .
```

#### 3. For Integration Tests
Set environment variables when running integration tests:
```bash
# Using pre-built images from your registry
export REGISTRY=ghcr.io
export REGISTRY_ORG=yourorg
./run-with-prebuilt.sh
```

Or in docker-compose:
```yaml
services:
  backend:
    image: ${REGISTRY:-ghcr.io}/${REGISTRY_ORG:-rpgoldberg}/figure-collector-backend:${TAG:-latest}
```

### Configuration Files

#### Dockerfiles
All production Dockerfiles support build arguments:
- `GITHUB_ORG`: GitHub organization (default: `rpgoldberg`)
- `GITHUB_REPO`: Repository name (default: service-specific)

Example:
```dockerfile
ARG GITHUB_ORG=rpgoldberg
ARG GITHUB_REPO=figure-collector-backend
LABEL org.opencontainers.image.source="https://github.com/${GITHUB_ORG}/${GITHUB_REPO}"
```

#### GitHub Actions
The CI/CD pipeline uses environment variables:
```yaml
env:
  REGISTRY: ghcr.io
  REGISTRY_ORG: ${{ github.repository_owner }}
```

#### Docker Compose
Integration tests use environment variable substitution:
```yaml
image: ${REGISTRY:-ghcr.io}/${REGISTRY_ORG:-rpgoldberg}/figure-collector-backend:${BACKEND_TAG:-develop}
```

### Forking Instructions

1. **Fork the repositories** to your GitHub account

2. **Update secrets** in GitHub repository settings:
   - `GITHUB_TOKEN` (automatically provided)
   - `SONAR_TOKEN` (if using SonarCloud)
   - `SLACK_WEBHOOK_URL` (optional)

3. **Enable GitHub Actions** in Settings → Actions

4. **No code changes needed!** The workflow automatically uses your organization name

### Custom Registry Setup

To use a private registry instead of GitHub Container Registry:

1. **Update workflow file** (`ci-cd-pipeline.yml`):
   ```yaml
   env:
     REGISTRY: your-registry.com
     REGISTRY_ORG: your-org
   ```

2. **Add registry credentials** as GitHub secrets:
   - `REGISTRY_USERNAME`
   - `REGISTRY_PASSWORD`

3. **Update login step** in workflow:
   ```yaml
   - name: Log in to Custom Registry
     uses: docker/login-action@v3
     with:
       registry: ${{ env.REGISTRY }}
       username: ${{ secrets.REGISTRY_USERNAME }}
       password: ${{ secrets.REGISTRY_PASSWORD }}
   ```

### Testing Your Configuration

1. **Build locally**:
   ```bash
   docker build \
     --build-arg GITHUB_ORG=yourorg \
     -t test-image \
     -f Dockerfile.production .
   ```

2. **Check image labels**:
   ```bash
   docker inspect test-image | grep source
   ```

3. **Run integration tests**:
   ```bash
   REGISTRY_ORG=yourorg ./run-with-prebuilt.sh
   ```

### Environment Variables Reference

| Variable | Default | Description |
|----------|---------|-------------|
| `REGISTRY` | `ghcr.io` | Docker registry URL |
| `REGISTRY_ORG` | `rpgoldberg` | Organization/username in registry |
| `BACKEND_TAG` | `develop` | Backend image tag |
| `FRONTEND_TAG` | `develop` | Frontend image tag |
| `SCRAPER_TAG` | `develop` | Scraper image tag |
| `VERSION_TAG` | `develop` | Version manager image tag |

### Troubleshooting

**Issue**: Images not found in registry
- **Solution**: Ensure images are built and pushed with correct organization name

**Issue**: Permission denied when pushing images
- **Solution**: Check registry credentials and permissions

**Issue**: Fork still using original organization
- **Solution**: GitHub Actions automatically uses your org, but check `REGISTRY_ORG` in workflow

### Best Practices

1. **Use environment variables** instead of hardcoding organization names
2. **Document your organization** in your fork's README
3. **Keep build args consistent** across all services
4. **Use semantic versioning** for image tags
5. **Test with local builds** before pushing to registry