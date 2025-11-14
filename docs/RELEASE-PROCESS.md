# Release Process for Figure Collector Services

## CRITICAL: Version Bump Timing

**VERSION BUMPS MUST HAPPEN IN THE PR BEFORE MERGING TO DEVELOP**

### Why This Matters
- User tests the develop branch images with Docker
- Version tracking files (version.json) must match actual package.json versions
- The version-manager UI shows "verified" vs "registered" based on these files matching develop
- Testing happens BEFORE release branches and tags are created

### For Every Service Release PR

**BEFORE merging to develop, the PR MUST include:**

1. **Feature implementation**
2. **Version bump in package.json** to the release version (e.g., 2.0.2 → 2.1.0)
3. **Updated version tracking files** (if infrastructure or version-manager)

### Version-Manager and Infrastructure

**These services ALWAYS get bumped when any service releases:**
- version-manager: Gets patch bump for compatibility tracking
- infrastructure: Matches application version (not independent)

### Example: v2.1.0 Release

**Backend PR #71 should have included:**
- Atlas Search feature
- package.json: `"version": "2.1.0"` ✓ (MUST be in PR)

**Frontend PR #74 should have included:**
- Dark mode feature
- package.json: `"version": "2.1.0"` ✓ (MUST be in PR)

**Version-Manager PR #49 should have included:**
- v2.1.0 compatibility tracking
- package.json: `"version": "1.1.4"` ✓ (MUST be in PR)

**Infrastructure commits should have included:**
- version.json updated to v2.1.0

## Workflow Summary

1. **Create feature branch** from develop
2. **Implement feature** with tests
3. **Bump package.json version** to release version
4. **Update version tracking** (if infra/version-manager)
5. **Create PR to develop**
6. **Merge PR** (versions already bumped)
7. **User tests develop** with correct versions
8. **After testing succeeds**, update `"released": "date"` in version.json testedCombinations
9. **Create release branches** from develop
10. **Tag releases** and merge to main

## What NOT to Do

❌ Merge PR with old version, then bump version on develop afterward
❌ Commit directly to develop for version bumps
❌ Forget to bump version-manager when other services release
❌ Forget to update version tracking files

## Version Tracking File

Located in `figure-collector-infra/`:

### version.json (Single Source of Truth)
- **ONLY** version source for Docker deployments and all services
- Tracks all service versions and compatibility matrix
- Must match package.json versions on develop
- **CRITICAL**: Version-manager Docker container loads this file
- Updated by `scripts/version-manager.sh` bump script

**Fields to update for each release:**
- `.application.version` - Application release version
- `.application.releaseDate` - Set to release date (or `null` if pending)
- `.services.*.version` - Each service's version
- `.services.*.dockerImage` - Docker image tags
- `.dependencies.*` - Service dependency versions
- `.compatibility.testedCombinations` - Add new combination with `verified: null` (or date)

## Mistakes Made (Nov 2025)

### Mistake #1: Version Bumps Not in PRs
During v2.1.0 release, PRs were merged WITHOUT version bumps in package.json:
- Backend merged at 2.0.2, should have been 2.1.0
- Frontend merged at 2.0.2, should have been 2.1.0
- Had to fix afterward with direct commits to develop (wrong!)

**Lesson:** Always bump versions IN THE PR before merging.

### Mistake #2: Created Duplicate Version Tracking File
During version tracking file updates:
- Created `application-versions.json` as duplicate/secondary tracking file
- Only updated application-versions.json to v2.1.0
- **FORGOT** to update version.json to v2.1.0
- Version-manager Docker container failed to start (JSON parsing error)
- Docker deployment couldn't test because version.json had wrong versions

**Lesson:** Maintain only ONE version tracking file (`version.json`). Multiple version files cause sync issues and deployment failures. The `application-versions.json` file has been **deleted** to prevent future confusion.

### Mistake #3: Committed Directly to Develop
Fixed the version.json issue by committing directly to develop instead of creating a PR:
- Bypassed CI/CD workflow (no Docker builds triggered)
- Bypassed PR review process
- Violated the protected branch workflow
- Deployment still broken because no new Docker images were built

**Lesson:** ALWAYS create a PR, even for urgent fixes. Direct commits bypass critical CI/CD steps.
