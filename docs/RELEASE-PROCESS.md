# Release Process for Figure Collector Services

## Core Principle: Version Bumps Before Merge

**ALL VERSION BUMPS HAPPEN IN THE PR BEFORE MERGING TO DEVELOP**

This ensures develop branch is always testable with correct version numbers.

## Simple Release Workflow

### 1. Create Feature PR
```bash
# In service directory (backend, frontend, scraper)
git checkout -b feature/my-feature
# Implement feature with tests
# Bump version in package.json manually
git add .
git commit -m "Add my feature"
git push -u origin feature/my-feature
gh pr create --base develop
```

### 2. Version Bumps Required

**For EVERY service release, these services MUST be bumped:**

| Service | Bump Type | Why |
|---------|-----------|-----|
| **Releasing service** | As appropriate (major/minor/patch) | The feature being released |
| **version-manager** | Always patch | Needs to track new compatibility combo |
| **infrastructure** | Only if docs changed | Infrastructure docs updated |

**Example: Backend v2.0.2 → v2.1.0 (minor feature)**
- ✅ backend/package.json: `"version": "2.1.0"`
- ✅ version-manager/package.json: `"version": "1.1.4"` (was 1.1.3)
- ✅ version-manager/version.json: Update all versions
- ✅ infrastructure/package.json: Only if docs changed

### 3. Update version.json (in version-manager repo)

**SINGLE SOURCE OF TRUTH**: `version-manager/version.json`

Edit manually to update:
```json
{
  "application": {
    "version": "2.1.0",
    "releaseDate": "15-Nov-2025"
  },
  "services": {
    "backend": { "version": "2.1.0", "dockerImage": "backend:v2.1.0" },
    "frontend": { "version": "2.1.0", "dockerImage": "frontend:v2.1.0" },
    "scraper": { "version": "2.0.3", "dockerImage": "scraper:v2.0.3" },
    "version-manager": { "version": "1.1.4", "dockerImage": "version-manager:v1.1.4" }
  },
  "compatibility": {
    "testedCombinations": [
      {
        "backend": "2.1.0",
        "frontend": "2.1.0",
        "scraper": "2.0.3",
        "version-manager": "1.1.4",
        "verified": null,
        "notes": "v2.1.0 release: Backend Atlas Search + Frontend Dark Mode"
      }
    ]
  }
}
```

### 4. Merge and Test
1. Merge PRs to develop
2. Docker builds trigger automatically
3. Test develop branch Docker images
4. Update `verified` field in version.json to release date once testing passes

### 5. Create Release
```bash
# After testing succeeds on develop
git checkout -b release/v2.1.0
git push -u origin release/v2.1.0
gh pr create --base main --title "Release v2.1.0"

# After merge to main, tag it
git checkout main
git pull
git tag -a v2.1.0 -m "Release v2.1.0"
git push origin v2.1.0
```

## What NOT to Do

❌ Merge PR without version bumps
❌ Commit directly to develop
❌ Forget to bump version-manager
❌ Use old bump scripts (deleted)
❌ Create multiple version.json files

## Troubleshooting

### "Unknown" showing in version footer
This means version.json is missing data (releaseDate null, version mismatch, etc.). Fix the data in version.json, don't hide the warning.

### Docker container won't start
Check version.json is valid JSON and contains all required service entries.

### Version mismatch after merge
Version bumps weren't in the PR. Create new PR with correct versions.

## Simplified Architecture

```
version-manager/version.json  ← SINGLE SOURCE OF TRUTH
  ↓
All services read from here (via version-manager service)
  ↓
Frontend displays in footer
```

**No more:**
- ❌ Bump scripts
- ❌ infrastructure/version.json
- ❌ Multiple version tracking files
- ❌ Complex sync processes

**Just:**
- ✅ Manual version bumps in package.json
- ✅ Manual updates to version-manager/version.json
- ✅ Simple, visible, reviewable
