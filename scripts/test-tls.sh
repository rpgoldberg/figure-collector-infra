#!/bin/bash
# Completely isolated TypeScript Language Server test

# Clear all potentially problematic environment variables
unset VSCODE_PID VSCODE_CWD VSCODE_IPC_HOOK_CLI TERM_PROGRAM TERM_PROGRAM_VERSION
unset WSLENV WSL_DISTRO_NAME WSL_INTEROP

# Set minimal PATH without Windows components
export PATH="/home/rgoldberg/.nvm/versions/node/v24.5.0/bin:/usr/local/bin:/usr/bin:/bin"
export HOME="/home/rgoldberg"

# Test TypeScript Language Server
echo "Testing TypeScript Language Server with isolated environment..."
timeout 5s typescript-language-server --stdio < /dev/null
echo "Exit code: $?"