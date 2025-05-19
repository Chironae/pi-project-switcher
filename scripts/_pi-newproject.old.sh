#!/bin/bash

PROJECTS_FILE="$HOME/.pi-project-switcher/projects.json"
PROJECTS_DIR="$HOME/projects"
TYPE="default"
PROJECT_NAME=""
PROJECT_PATH=""
SWITCHER_ROOT="$(cd "$(dirname "$0")"/.. && pwd)"

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --type)
      TYPE="$2"
      shift 2
      ;;
    *)
      PROJECT_NAME="$1"
      shift
      ;;
  esac
done

if [[ -z "$PROJECT_NAME" ]]; then
    echo "Usage: pi-newproject <projectname> [--type cli]"
    exit 1
fi

PROJECT_PATH="$PROJECTS_DIR/$PROJECT_NAME"

# Prevent overwriting existing projects
if [ -d "$PROJECT_PATH" ]; then
    echo "Project folder $PROJECT_PATH already exists."
    exit 1
fi

echo "🔧 Creating new project at: $PROJECT_PATH"

if [[ "$TYPE" == "cli" ]]; then
    echo "📦 Cloning CLI template..."
    git clone https://github.com/Chironae/pi-cli-template.git "$PROJECT_PATH"

    cd "$PROJECT_PATH" || exit 1

    echo "⚙️  Running setup script..."
    chmod +x setup.sh
    ./setup.sh

    echo "✅ CLI project created from pi-cli-template."
    echo "🧪 Next steps:"
    echo "  - cd $PROJECT_PATH"
    echo "  - nano your-script.sh"
    echo "  - make release"
    echo "  - ./your-script.sh --help"
else
    echo "📁 Making blank project folder structure..."
    mkdir -p "$PROJECT_PATH"
    touch "$PROJECT_PATH/README.md"
    echo "# $PROJECT_NAME" > "$PROJECT_PATH/README.md"
    echo "✅ Default blank project created."
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

# === Optional Checkin Tool Integration ===
if [[ "$@" == *"--enable-checkin"* ]]; then
  echo "📦 Enabling Pi Checkin Tool for this project..."

  mkdir -p "$PROJECT_PATH/scripts"
  mkdir -p "$PROJECT_PATH/config"

  # Symlink the master tool script
  ln -s "$SWITCHER_ROOT/tools/pi-checkin-tool.sh" "$PROJECT_PATH/scripts/pi-checkin-tool.sh"

  # Drop default config
  cat > "$PROJECT_PATH/config/pi-checkin-config.json" <<EOF
{
  "notes_file": "NOTES.md",
  "changelog_file": "CHANGELOG.md",
  "roadmap_file": "ROADMAP.md",
  "default_branch": "master",
  "enable_push": true
}
EOF

# Add README starter snippet
cat >> "$PROJECT_PATH/README.md" <<'EOF'

---

### 📓 Daily Checkins

This project uses the [Pi Checkin Tool](../pi-project-switcher/tools/pi-checkin-tool.sh) to log daily work and commit summaries.

#### Usage

Run interactively:
```bash
./scripts/pi-checkin-tool.sh

Quick push mode (no prompts):
./scripts/pi-checkin-tool.sh --quick

You can configure settings in `config/pi-checkin-config.json`

EOF
fi

echo "Project '$PROJECT_NAME' scaffolded at $PROJECT_PATH and added to registry."
