#!/bin/bash

PROJECTS_FILE="$HOME/.pi-project-switcher/projects.json"
PROJECTS_DIR="$HOME/projects"
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE"
done
SWITCHER_ROOT="$(cd -P "$(dirname "$SOURCE")/.." >/dev/null 2>&1 && pwd)"
echo "💡 SWITCHER_ROOT is: $SWITCHER_ROOT"
ENV_TRACKER_FILE="$HOME/.pi-project-switcher/last_env_keys.txt"

ensure_registry() {
  if [ ! -f "$PROJECTS_FILE" ]; then
    mkdir -p "$(dirname "$PROJECTS_FILE")"
    echo '{ "projects": {}, "default_project": "" }' > "$PROJECTS_FILE"
  fi
}

register_project() {
  ensure_registry
  jq --arg name "$1" --arg path "$2" \
    '.projects[$name] = { "path": $path, "venv": false, "default_backend": "github" }' \
    "$PROJECTS_FILE" > "$PROJECTS_FILE.tmp" && mv "$PROJECTS_FILE.tmp" "$PROJECTS_FILE"
}

switch_project() {
  if [ -f "$ENV_TRACKER_FILE" ]; then
    echo "🚹 Clearing previous environment variables..."
    while read -r var; do
      unset "$var"
    done < "$ENV_TRACKER_FILE"
    rm -f "$ENV_TRACKER_FILE"
  fi

  > "$ENV_TRACKER_FILE"

  local name="$1"
  local dry_run=false

  if [[ "$2" == "--dry-run" ]]; then
    dry_run=true
  fi
  ensure_registry

  if [[ -z "$name" ]]; then
    name=$(jq -r '.default_project // empty' "$PROJECTS_FILE")
    if [[ -z "$name" ]]; then
      echo "❌ No project name provided and no default project is set."
      exit 1
    fi
    echo "⭐ No project name provided. Using default: $name"
  fi

  local path="$PROJECTS_DIR/$name"

  if [ ! -d "$path" ]; then
    echo "❌ Project '$name' not found at $path"
    exit 1
  fi

  cd "$path" || exit 1
  echo "✅ Switched to $path"

  if [ -f ".env.defaults" ]; then
    echo "🛠️ Applying .env.defaults..."
    while IFS='=' read -r key value || [ -n "$key" ]; do
      [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
      if [ -z "${!key}" ]; then
        if ! grep -qx "$key" "$ENV_TRACKER_FILE"; then
          echo "$key" >> "$ENV_TRACKER_FILE"
        fi
        if [ "$dry_run" = false ]; then
          export "$key=$value"
        fi
        echo "  🟡 $key=$value (default)"
      fi
    done < .env.defaults
  fi

  if [ -f ".env" ]; then
    echo "📆 Loading .env..."
    while IFS='=' read -r key value || [ -n "$key" ]; do
      [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
      if ! grep -qx "$key" "$ENV_TRACKER_FILE"; then
        echo "$key" >> "$ENV_TRACKER_FILE"
      fi
      if [ "$dry_run" = false ]; then
        export "$key=$value"
      fi
      if [[ "$key" =~ (SECRET|TOKEN|KEY|PASS) ]]; then
        echo "  🔐 $key=********"
      else
        echo "  ✅ $key=$value"
      fi
    done < .env
  fi

  if [ -f ".env.sh" ]; then
    echo "🔁 Running .env.sh overrides..."
    if [ "$dry_run" = false ]; then
      source .env.sh
      grep -E '^[[:space:]]*export[[:space:]]+[A-Z0-9_]+=' .env.sh | sed -E 's/^[[:space:]]*export[[:space:]]+//' | while IFS='=' read -r key value; do
        value="${!key}"
        if ! grep -qx "$key" "$ENV_TRACKER_FILE"; then
          echo "$key" >> "$ENV_TRACKER_FILE"
        fi
        if [[ "$key" =~ (SECRET|TOKEN|KEY|PASS) ]]; then
          echo "  🔐 $key=******** (override)"
        else
          echo "  🔄 $key=$value"
        fi
      done
    else
      echo "  ⚠️ (dry run – .env.sh not executed)"
    fi
  fi

  if [ -f "venv/bin/activate" ]; then
    echo "🐍 Activating virtual environment..."
    source venv/bin/activate
  fi

  exec bash
}

new_project() {
  local args=("$@")
  local type="default"
  local project_name=""
  local project_path=""

  while [[ ${#args[@]} -gt 0 ]]; do
    case "${args[0]}" in
      --type)
        type="${args[1]}"
        args=("${args[@]:2}")
        ;;
      *)
        project_name="${args[0]}"
        args=("${args[@]:1}")
        ;;
    esac
  done

  if [[ -z "$project_name" ]]; then
    echo "Usage: pi-switcher new <projectname> [--type cli]"
    exit 1
  fi

  project_path="$PROJECTS_DIR/$project_name"

  if [ -d "$project_path" ]; then
    echo "❌ Project folder $project_path already exists."
    exit 1
  fi

  echo "🔧 Creating new project at: $project_path"

  if [[ "$type" == "cli" ]]; then
    echo "📦 Cloning CLI template..."
    git clone https://github.com/Chironae/pi-cli-template.git "$project_path"
    cd "$project_path" || exit 1
    echo "⚙️ Running setup script..."
    chmod +x setup.sh
    ./setup.sh
    echo "✅ CLI project created from pi-cli-template."
    echo "🧪 Next steps:"
    echo "  - cd $project_path"
    echo "  - nano your-script.sh"
    echo "  - make release"
    echo "  - ./your-script.sh --help"
  else
    mkdir -p "$project_path"
    touch "$project_path/README.md"
    echo "# $project_name" > "$project_path/README.md"
    echo "✅ Default blank project created."
  fi

  register_project "$project_name" "$project_path"
  echo "📁 Project '$project_name' scaffolded at $project_path and added to registry."
}

list_projects() {
  ensure_registry
  case "$1" in
    --json)
      cat "$PROJECTS_FILE"
      ;;
    --full)
      echo "📂 Registered Projects (detailed):"
      jq -r '
        . as $root |
        .projects | to_entries[] |
        "  \(.key)\(if $root.default_project == .key then " ⭐" else "" end):\n    path: \(.value.path)\n    venv: \(.value.venv)\n    backend: \(.value.default_backend // "n/a")"
      ' "$PROJECTS_FILE"
      ;;
    *)
      echo "📂 Registered Projects:"
      jq -r '.projects | to_entries[] | "  \(.key): \(.value.path)"' "$PROJECTS_FILE"
      ;;
  esac
}

remove_project() {
  local name="$1"
  ensure_registry
  if ! jq -e --arg name "$name" '.projects[$name]' "$PROJECTS_FILE" > /dev/null; then
    echo "❌ Project '$name' not found in registry."
    exit 1
  fi
  jq --arg name "$name" 'del(.projects[$name])' "$PROJECTS_FILE" > "$PROJECTS_FILE.tmp" && mv "$PROJECTS_FILE.tmp" "$PROJECTS_FILE"
  echo "🗑️ Project '$name' removed from registry."
}

set_default_project() {
  local name="$1"
  ensure_registry
  if ! jq -e --arg name "$name" '.projects[$name]' "$PROJECTS_FILE" > /dev/null; then
    echo "❌ Project '$name' not found in registry."
    exit 1
  fi
  jq --arg name "$name" '.default_project = $name' "$PROJECTS_FILE" > "$PROJECTS_FILE.tmp" && mv "$PROJECTS_FILE.tmp" "$PROJECTS_FILE"
  echo "⭐ Default project set to '$name'"
}

get_git_config() {
  CONFIG_FILE="$HOME/.pi-switcher/git-config.json"
  if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Git config not found. Create one with: pi-switcher git-config init"
    exit 1
  fi
}

cmd_git_config() {
  get_git_config

  case "$1" in
    set)
      key="$2"
      value="$3"
      if [[ -z "$key" || -z "$value" ]]; then
        echo "Usage: pi-switcher git-config set <key> <value>"
        exit 1
      fi
      jq --arg k "$key" --arg v "$value" '.[$k] = $v' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
      echo "✅ Set $key = $value"
      ;;
    unset)
      key="$2"
      if [[ -z "$key" ]]; then
        echo "Usage: pi-switcher git-config unset <key>"
        exit 1
      fi
      jq "del(.$key)" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
      echo "🗑️  Removed $key"
      ;;
    *)
      echo "📄 Current Git Config:"
      jq . "$CONFIG_FILE"
      ;;
  esac
}

case "$1" in
  new)
    shift
    new_project "$@"
    ;;
  switch)
    shift
    switch_project "$@"
    ;;
  list)
    shift
    list_projects "$@"
    ;;
  remove)
    shift
    remove_project "$@"
    ;;
  set-default)
    shift
    set_default_project "$@"
    ;;
  clean)
    if [ -f "$ENV_TRACKER_FILE" ]; then
      echo "🚼 Unsetting variables from previous session..."
      while read -r var; do
        if [[ -n "${!var}" ]]; then
          echo "  🗑️  Unsetting $var"
          unset "$var"
        else
          echo "  ⚠️  $var was not set"
        fi
      done < "$ENV_TRACKER_FILE"
      rm -f "$ENV_TRACKER_FILE"
      echo "✅ Environment cleaned."
      echo "♻️  Restarting shell to finalize cleanup..."
      exec bash
    else
      echo "ℹ️  No tracked environment variables to clean."
    fi
    ;;
  release)
    shift
    bash "$SWITCHER_ROOT/scripts/release/finalize_release.sh"
    ;;
  git-config)
    shift
    cmd_git_config "$@"
    ;;
  git-audit)
    shift
    bash "$SWITCHER_ROOT/scripts/git/git_audit.sh" "$@"
    ;;
  ssh-keys)
    shift
    bash "$SWITCHER_ROOT/scripts/git/manage_ssh_keys.sh" "$@"
    ;;
  ssh-config)
    bash "$SWITCHER_ROOT/scripts/git/sync_ssh_config.sh"
    ;;
  help|*)
    [[ "$1" == "help" ]] && echo -e "📖 Help Menu\n" || echo -e "🤷‍♂️  Unknown command: '$1'\n"
    echo "Here’s what you *can* do:"
    echo "  🔨  pi-switcher new <projectname> [--type cli]     # scaffold a new project"
    echo "  🔄  pi-switcher switch [projectname]              # jump to a project (default if none)"
    echo "  📂  pi-switcher list [--full|--json]              # list all registered projects"
    echo "  🗑️  pi-switcher remove <projectname>             # remove a project from registry"
    echo "  ⭐  pi-switcher set-default <projectname>         # set the default project"
    echo "  🚼  pi-switcher clean                            # unset env vars without switching"
    exit 1
    ;;
esac
