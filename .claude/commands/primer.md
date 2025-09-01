## Figure Collector Infrastructure Primer Command

**IMPORTANT**: This is the figure-collector-infra service - infrastructure management, deployment automation, and system orchestration for the Figure Collector application.

### Step 1: Service Configuration
1. Read `CLAUDE.md` for service-specific configuration and agent instructions
2. Understand this service's role as the infrastructure and deployment layer for the entire Figure Collector system

### Step 2: Service Structure Analysis

**Infrastructure Components**:
- Read `docker-compose.yml` for production service orchestration
- Read `docker-compose.test.yml` for testing environment configuration
- Review `deployment/` directory for platform-specific deployment configurations
- Check `scripts/` directory for automation and utility scripts
- Review version management and release processes

**Deployment Configurations**:
- Examine `deployment/cloudflare/` for CDN and DNS setup
- Review `deployment/coolify/` for self-hosted deployment platform
- Check `deployment/mongodb/` for database configuration and setup
- Understand environment-specific configurations and secrets management

**Automation Scripts**:
- Review `scripts/deploy.sh` for deployment automation
- Check `scripts/run-all-tests.sh` for comprehensive testing
- Examine utility scripts for maintenance and operations
- Review backup and monitoring scripts

**Documentation and Processes**:
- Read `DEPLOYMENT.md` for deployment procedures and guidelines
- Review `VERSIONING.md` for version management processes
- Check `GIT-FLOW-VERSIONING.md` for git workflow and release management
- Examine operational runbooks and procedures

### Step 3: Service Understanding

**Infrastructure Management**:
- Docker-based service orchestration and containerization
- Multi-environment deployment (development, staging, production)
- Service networking and communication configuration
- Resource management and scaling policies
- Monitoring and logging infrastructure

**Deployment Automation**:
- Automated deployment pipelines and processes
- Environment-specific configuration management
- Secret and credential management
- Database migration and versioning
- Zero-downtime deployment strategies

**Platform Integration**:
- Cloudflare integration for CDN and security
- Coolify self-hosted deployment platform
- MongoDB Atlas database management
- SSL/TLS certificate management
- Domain and DNS configuration

**Operational Procedures**:
- Backup and disaster recovery processes
- Monitoring and alerting setup
- Performance optimization and tuning
- Security hardening and compliance
- Incident response and troubleshooting

### Step 4: Available Tools and Agents

**Available Sub-Agents**:
- `infrastructure-manager` (Haiku) - Infrastructure automation and deployment specialist
- `documentation-manager` (Haiku) - Documentation synchronization
- `validation-gates` - Testing and validation specialist

**Infrastructure Commands**:
- `./scripts/deploy.sh` - Automated deployment execution
- `./scripts/run-all-tests.sh` - Comprehensive system testing
- `docker-compose up -d` - Production service startup
- `./scripts/backup.sh` - Database backup procedures
- Platform-specific deployment commands

### Step 5: Summary Report

After analysis, provide:
- **Service Purpose**: Infrastructure management and deployment automation for Figure Collector
- **Technology Stack**: Docker, Docker Compose, deployment automation, monitoring
- **Key Functionality**: Service orchestration, deployment automation, environment management
- **Infrastructure Components**: Container orchestration, networking, storage, monitoring
- **Deployment Platforms**: Cloudflare, Coolify, MongoDB Atlas, custom deployment
- **Automation Scripts**: Deployment, testing, backup, maintenance procedures
- **Configuration Management**: Environment-specific configs, secrets, scaling policies
- **Operational Procedures**: Monitoring, backup, disaster recovery, incident response
- **Development Workflow**: Infrastructure setup, deployment, and maintenance processes

**Remember**: This service manages critical infrastructure - security, reliability, and disaster recovery are paramount considerations for all changes.