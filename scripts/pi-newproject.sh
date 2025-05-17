#!/bin/bash

PROJECTS_FILE="$HOME/.pi-project-switcher/projects.json"
PROJECTS_DIR="$HOME/projects"
PROJECT_NAME="$1"

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: pi-newproject <projectname>"
    exit 1
fi

PROJECT_PATH="$PROJECTS_DIR/$PROJECT_NAME"

# Prevent overwriting existing projects
if [ -d "$PROJECT_PATH" ]; then
    echo "Project folder $PROJECT_PATH already exists."
    exit 1
fi

# Scaffold basic folders
mkdir -p "$PROJECT_PATH"/{config,scripts,docs,data,venv}

# Create dummy files
echo "# $PROJECT_NAME Project" > "$PROJECT_PATH/docs/README.md"
echo "# NOTES for $PROJECT_NAME" > "$PROJECT_PATH/docs/NOTES.md"
echo "# ROADMAP for $PROJECT_NAME" > "$PROJECT_PATH/docs/ROADMAP.md"
echo "# Ignore data & venv" > "$PROJECT_PATH/.gitignore"
echo "/data/" >> "$PROJECT_PATH/.gitignore"
echo "/venv/" >> "$PROJECT_PATH/.gitignore"
echo ".env" >> "$PROJECT_PATH/.gitignore"

# Initialize git repo
cd "$PROJECT_PATH" || exit 1
git init

# Update registry (add project entry)
mkdir -p "$(dirname "$PROJECTS_FILE")"
if [ ! -f "$PROJECTS_FILE" ]; then
    echo '{"projects":{}}' > "$PROJECTS_FILE"
fi

jq --arg proj "$PROJECT_NAME" --arg path "$PROJECT_PATH" \
    '.projects[$proj] = { "path": $path, "venv": false, "default_backend": "github" }' \
    "$PROJECTS_FILE" > "$PROJECTS_FILE.tmp" && mv "$PROJECTS_FILE.tmp" "$PROJECTS_FILE"

echo "Project '$PROJECT_NAME' scaffolded at $PROJECT_PATH and added to registry."
