# Local Development Setup

## Quick Start

From the `figure-collector-infra` directory:

```bash
# Start all services in development mode (uses .env.dev automatically)
docker-compose -f docker-compose.dev.yml --env-file .env.dev up --build

# Or start in background
docker-compose -f docker-compose.dev.yml --env-file .env.dev up -d --build
```

**Note**: The `.env.dev` file is required and contains all environment variables matching your Coolify dev configuration.

## Access Services

Once running, access in your browser (ports match Coolify dev configuration):

- **Frontend**: http://localhost:5071
- **Backend API**: http://localhost:5070
  - Health: http://localhost:5070/health
  - API docs: http://localhost:5070/api
- **Scraper**: http://localhost:3010
  - Health: http://localhost:3010/health
- **Version Manager**: http://localhost:3011
  - Health: http://localhost:3011/health
- **MongoDB**: localhost:27017

## Development Features

- **Hot Reload**: Code changes automatically restart services (nodemon)
- **Volume Mounts**: Source code is mounted, no rebuild needed for changes
- **Local MongoDB**: Persistent data in Docker volume
- **Development Stage**: Includes all dev dependencies and debugging tools
- **Coolify Parity**: Ports match your Coolify dev environment

## Individual Service Development

If you only want to run specific services:

```bash
# Backend only (with MongoDB)
docker-compose -f docker-compose.dev.yml up backend mongodb

# Frontend only (requires backend running)
docker-compose -f docker-compose.dev.yml up frontend

# Scraper only
docker-compose -f docker-compose.dev.yml up scraper
```

## Alternative: Run Without Docker Compose

### Backend
```bash
cd figure-collector-backend
docker build --target development -t backend-dev .
docker run -p 5070:5070 \
  -e PORT=5070 \
  -e MONGODB_URI=mongodb://host.docker.internal:27017/figure-collector-dev \
  -e JWT_SECRET=dev-secret \
  -v $(pwd)/src:/app/src \
  backend-dev
```

### Frontend
```bash
cd figure-collector-frontend
docker build --target development -t frontend-dev .
docker run -p 5071:5071 \
  -e PORT=5071 \
  -e REACT_APP_API_URL=http://localhost:5070 \
  -v $(pwd)/src:/app/src \
  frontend-dev
```

### Page Scraper
```bash
cd page-scraper
docker build --target development -t scraper-dev .
docker run -p 3010:3010 \
  -e PORT=3010 \
  --shm-size=2gb \
  -v $(pwd)/src:/app/src \
  scraper-dev
```

### Version Manager
```bash
cd version-manager
docker build --target development -t version-dev .
docker run -p 3011:3011 \
  -e PORT=3011 \
  -v $(pwd):/app \
  version-dev
```

## Stopping Services

```bash
# Stop all services
docker-compose -f docker-compose.dev.yml down

# Stop and remove volumes (clears database)
docker-compose -f docker-compose.dev.yml down -v
```

## Troubleshooting

### Port conflicts
If ports are already in use, check what's using them:
```bash
lsof -i :5070  # Backend
lsof -i :5071  # Frontend
lsof -i :3010  # Scraper
lsof -i :3011  # Version Manager
```

### MongoDB connection issues
Make sure MongoDB is running:
```bash
docker-compose -f docker-compose.dev.yml ps mongodb
```

Check logs:
```bash
docker-compose -f docker-compose.dev.yml logs mongodb
```

### Code changes not reflecting
The volume mounts should handle this, but if needed:
```bash
docker-compose -f docker-compose.dev.yml restart backend
```

### Rebuilding after dependency changes
If you modify `package.json`:
```bash
docker-compose -f docker-compose.dev.yml up --build
```

### Check service logs
```bash
# All services
docker-compose -f docker-compose.dev.yml logs -f

# Specific service
docker-compose -f docker-compose.dev.yml logs -f backend
```

### Frontend API 404 errors
If the frontend shows 404 errors for API requests like `/api/figures/*`:

**Cause**: Missing or misconfigured proxy middleware

**Solution**: The frontend uses `src/setupProxy.js` to proxy API requests:
- Requires `http-proxy-middleware` package (should be installed)
- Rewrites `/api/*` → `/*` when forwarding to backend
- If missing, API requests will hit the frontend server (port 5071) instead of backend (port 5070)

**Verify proxy is working**:
```bash
docker logs figure-collector-frontend-dev | grep HPM
# Should show: [HPM] Proxy created and [HPM] Proxy rewrite rule created
```

### Docker cache/build errors (KeyError: 'ContainerConfig')
If you get `KeyError: 'ContainerConfig'` or similar Docker metadata errors:

**Cause**: Docker Compose cached metadata conflicts with configuration changes

**Solution**: Clean up containers and images:
```bash
# Stop and remove all containers
docker-compose -f docker-compose.dev.yml down --remove-orphans

# Remove specific service containers and images
docker rm -f figure-collector-frontend-dev
docker rmi $(docker images -q 'figure-collector-infra*frontend*')

# Rebuild fresh
docker-compose -f docker-compose.dev.yml up --build -d
```

**Note**: This is a Docker Compose bug that occurs when configuration changes between builds. The manual cleanup above is the recommended fix.

### webpack-dev-server compatibility
The frontend uses react-scripts 5.0.1 which requires webpack-dev-server 4.x.

**Important**: Do NOT add `webpack-dev-server` to package.json overrides - this causes compatibility issues.

If you see errors like `unknown property 'onAfterSetupMiddleware'`:
- Check that package.json does NOT have webpack-dev-server in overrides section
- Let react-scripts use its bundled compatible version

## Environment Variables

The `.env.dev` file includes all necessary variables:

### Required Variables (Already Set)
- **ENVIRONMENT**: `development`
- **Service Names**: Container names with `-dev` suffix
- **Ports**: 5070 (backend), 5071 (frontend), 3010 (scraper), 3011 (version-manager)
- **MONGODB_URI**: Local MongoDB connection
- **JWT Secrets**: Development secrets (32+ characters)
- **SERVICE_AUTH_TOKEN**: For service-to-service authentication
- **Service URLs**: Internal Docker network URLs

### Customization
If you need different settings, copy `.env.dev` to `.env.local`:
```bash
cp .env.dev .env.local
# Edit .env.local with your custom settings
docker-compose -f docker-compose.dev.yml --env-file .env.local up
```

### Using Atlas MongoDB Instead of Local
Edit `.env.dev` (or `.env.local`) and update:
```bash
MONGODB_URI=mongodb+srv://<username>:<password>@<cluster>.mongodb.net/figure-collector-dev?retryWrites=true&w=majority
```

Then remove the MongoDB service from startup:
```bash
docker-compose -f docker-compose.dev.yml --env-file .env.dev up backend frontend scraper version-manager
```

## Port Reference

| Service | Dev Port | Test Port | Prod Port | Notes |
|---------|----------|-----------|-----------|-------|
| Backend | 5070 | 5055 | 5050 | REST API |
| Frontend | 5071 | 5056 | 5051 | React SPA |
| Scraper | 3010 | 3005 | 3000 | Puppeteer service |
| Version Manager | 3011 | 3006 | 3011 | Version coordination |
| MongoDB | 27017 | 27017 | - | Dev/Test only |
