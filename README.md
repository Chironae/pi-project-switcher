Pi Project Switcher
A simple tool for managing isolated project environments on Raspberry Pi.

✨ Features
🔄 Context-based project switching with environment variable loading

🐍 Per-project virtual environment activation and clean deactivation

🏗️ Standardized project folder scaffolding

🗂️ JSON-based registry for tracking projects and configurations

🚀 Expandable for task automation, check-in tools, and external integrations

📁 Folder Structure
pi-project-switcher/
scripts/
pi-switch.sh
pi-newproject.sh
examples/
sandbox_cheatsheet.md
README.md

🛠️ Usage
Create a New Project:
./scripts/pi-newproject.sh <projectname>

Switch to a Project Context:
source ./scripts/pi-switch.sh <projectname>

Venv Handling:

🛡️ Existing venv is deactivated when switching projects

✅ Target project's venv is activated if configured in projects.json

🚫 Projects without a venv are handled cleanly

Example Alias for Convenience:
alias piswitch='source ~/pi-project-switcher/scripts/pi-switch.sh'

Then use:
piswitch sandbox

⚙️ Configuration
Projects and their configurations are managed in:
~/.pi-project-switcher/projects.json

Example entry:
"myproject": {
"path": "/home/pi/projects/myproject",
"venv": true
}

🗺️ Roadmap
🔌 Adapter support for GitHub, Azure DevOps, and other platforms

📝 Integrated Pi Checkin Tool for end-of-day task tracking

🧰 Template-based project scaffolding for common use cases

📝 License
MIT License
