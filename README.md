# 🛠️ Pi Project Switcher

A lightweight, no-bloat tool for managing isolated project environments on your Raspberry Pi.

Think of it as your **context switcher with manners** — easily moving between projects, activating venvs, and loading configurations without path hell.

---

## ✨ Features
- 🔄 Context-based project switching with environment variable loading
- 🐍 Per-project virtual environment activation & clean deactivation
- 🏗️ Standardized project scaffolding with `pi-newproject.sh`
- 🗂️ JSON-based project registry to track paths & venv status
- 🚀 Expandable for future integrations (GitHub, Azure DevOps, Checkin Tools)

---

## 📁 Folder Structure
pi-project-switcher/
  scripts/
    pi-switch.sh
    pi-newproject.sh
  examples/
    sandbox_cheatsheet.md
  .gitignore
  LICENSE
  README.md
  CONTRIBUTING.md
  CHANGELOG.md
  ROADMAP.md

---

## 🚀 Usage

➡️ **Switch to a Project**
  source ./scripts/pi-switch.sh <projectname>

➡️ **Create a New Project**
  ./scripts/pi-newproject.sh <projectname>

➡️ **Alias for Convenience**
  alias piswitch='source ~/pi-switch.sh'
  piswitch sandbox

---

## 🐍 Venv Handling
- Deactivates any active venv when switching projects
- Activates target project's venv if configured in `projects.json`
- Projects without venv config are handled cleanly without error

---

## ⚙️ Configuration
- Registry managed in: `~/.pi-project-switcher/projects.json`
- Example entry:
  "myproject": {
    "path": "/home/pi/projects/myproject",
    "venv": true
  }

---

## 🛣️ Roadmap Highlights
- Integrate Pi Checkin Tool for structured end-of-day task logging
- Adapter support for GitHub / Azure DevOps
- Template-based scaffolding profiles (e.g., VibeCRM)
- Enhanced project context management
- Optional project dashboards

---

## 🤝 Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

---

## 📜 License
MIT License. Because tools should stay fixable by their users.

---
