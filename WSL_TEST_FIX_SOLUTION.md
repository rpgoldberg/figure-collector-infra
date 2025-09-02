# WSL Testing Fix

## Problem
Mixed Windows/Linux Node.js setup causing Jest test failures:
- `npm` from Windows (`/mnt/c/program files/nodejs/npm`)
- `node` from Linux (`/usr/bin/node`)
- Results in UNC path errors and "C:\Windows" directory issues

## Fix
Install Node.js via NVM in WSL to ensure both npm and node are Linux-only:

```bash
# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Load NVM and install Node.js
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install node
nvm use node
```

## Running Tests
Always load NVM before npm commands in WSL:

```bash
export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && npm test
```

## Permanent Setup (Recommended)
Add to `~/.bashrc`:

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

Then restart your shell or run `source ~/.bashrc`.

## Verification
After fix, both should be Linux paths:
```bash
$ which npm && which node
/home/user/.nvm/versions/node/v24.5.0/bin/npm
/home/user/.nvm/versions/node/v24.5.0/bin/node
```

✅ No more Windows path errors, Jest finds configs, tests run normally.