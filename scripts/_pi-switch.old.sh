#!/bin/bash

PROJECTS_FILE="$HOME/.pi-project-switcher/projects.json"
DEFAULT_PROJECT=""
TARGET_PROJECT="$1"

# Load default project from registry
if [ -f "$PROJECTS_FILE" ]; then
    DEFAULT_PROJECT=$(jq -r '.default_project // empty' "$PROJECTS_FILE")
else
    echo "Projects file not found at $PROJECTS_FILE"
    exit 1
fi

# If no argument, use default
if [ -z "$TARGET_PROJECT" ]; then
    if [ -z "$DEFAULT_PROJECT" ]; then
        echo "No project specified and no default set."
        exit 1
    fi
    TARGET_PROJECT="$DEFAULT_PROJECT"
fi

# Get project path from registry
PROJECT_PATH=$(jq -r --arg proj "$TARGET_PROJECT" '.projects[$proj].path // empty' "$PROJECTS_FILE")

if [ -z "$PROJECT_PATH" ]; then
    echo "Project '$TARGET_PROJECT' not found in registry."
    exit 1
fi

# Do the switch: cd and source env if exists
echo "Switching to project: $TARGET_PROJECT"
cd "$PROJECT_PATH" || { echo "Failed to cd to $PROJECT_PATH"; exit 1; }

# Source config/env if exists
if [ -f "config/env" ]; then
    echo "Loading environment variables from config/env"
    source "config/env"
fi

# Activate venv if configured & exists
USE_VENV=$(jq -r --arg proj "$TARGET_PROJECT" '.projects[$proj].venv // false' "$PROJECTS_FILE")
if [ "$USE_VENV" = "true" ] && [ -f "venv/bin/activate" ]; then
    echo "Activating virtual environment"
    source "venv/bin/activate"
fi

echo "Project '$TARGET_PROJECT' is now active."
exec $SHELL
